require 'net/http'
require 'net/https'
require 'nokogiri'

# note : there is a problem with nested hash parameter which need monkey patch
# http://apidock.com/ruby/Net/HTTPHeader/set_form_data

# Adapted from http://snippets.dzone.com/posts/show/6776
class Hash
  def flatten_keys(newhash={}, keys=nil)
    self.each do |k, v|
      k = k.to_s
      keys2 = keys ? keys+"[#{k}]" : k
      if v.is_a?(Hash)
        v.flatten_keys(newhash, keys2)
      else
        newhash[keys2] = v
      end
    end
    newhash
  end
end

module ImOrder
  class ServerError < StandardError
  end

  class Response
    attr_accessor :xml, :type

    def initialize(raw)
      @xml=Nokogiri::XML.parse(raw)
      @type=self.result["type"]
    end

    def result
      @xml.root.search("//result").first
    end
  end

  class ResponseError < Response
    attr_accessor :code, :message

    def initialize(raw)
      super
      @code=self.result["code"]
      @message=self.result.text
    end

    def exception
      ImOrder.const_get(@code)
    end

    def to_s
      "ImOrder::ResponseError:#{@code}: #{@message}"
    end
  end

  class ResponseWarning < Response
    attr_accessor :id, :code, :message

    def initialize(raw)
      super
      @id=self.result["id"]
      @code=self.result["code"]
      @message=self.result.text
    end

    def to_s
      "ImOrder::ResponseError:#{@code}: #{@id} #{@message}"
    end
  end

  def self.parse_response(body)
    r=Response.new(body)
    case r.type
      when "Error"
        ResponseError.new(body)
      when "Warning"
        ResponseWarning.new(body)
      else
        r
    end
  end

  class Client

    def self.domain
      "ws.immateriel.fr"
    end

    def initialize(url)
      @url=url
    end

    def normalize_params(params, key=nil)
      params = params.flatten_keys if params.is_a?(Hash)
      result = {}
      params.each do |k,v|
        case v
          when Hash
            result[k.to_s] = normalize_params(v)
          when Array
            v.each_with_index do |val,i|
              result["#{k.to_s}[#{i}]"] = val.to_s
            end
          else
            result[k.to_s] = v.to_s
        end
      end
      result
    end

    def request(parameters)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(normalize_params(parameters))
      response = http.request(request)

      if response.code.to_i/200 == 1
        ImOrder.parse_response(response.body)
      else
        raise ServerError, response.code
      end
    end
  end

end