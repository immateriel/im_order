require 'net/http'
require 'net/https'
require 'nokogiri'

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

  class Client
    def initialize(url)
      @url=url
    end

    def request(parameters)
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(parameters)
      response = http.request(request)

      if response.code.to_i/200 == 1
        r=Response.new(response.body)
        case r.type
          when "Error"
            ResponseError.new(response.body)
          when "Warning"
            ResponseWarning.new(response.body)
          else
            r
        end
      else
        raise ServerError, response.code
      end
    end
  end
end