require 'net/http'
require 'net/https'
require 'nokogiri'

require 'order/download'
require 'order/error'

module ImOrder
  class Customer
    include DownloadList
    attr_accessor :uid, :id, :password, :error, :warning

    def initialize(uid, email=nil, firstname=nil, lastname=nil, country=nil)
      @uid=uid
      @email=email
      @firstname=firstname
      @lastname=lastname
      @country=country

      @id=nil
      @password=nil
      @error=nil
      @warning=nil
    end

    def to_params
      {"customer_uid" => @uid, "email" => @email, "firstname" => @firstname, "lastname" => @lastname, "country" => @country}
    end

    def push(auth)
      if @email and @firstname and @lastname and @country
        client=ImOrder::Client.new("https://#{ImOrder::Client.domain}/fr/web_service/push_customer")

        parameters=auth.to_params
        parameters=parameters.merge(self.to_params)

        resp=client.request(parameters)

        case resp
          when ResponseError
            @error=resp
            raise resp.exception, resp.message
          when ResponseWarning
            @warning=resp
            @id=resp.result["id"]
            false
          when Response
            @id=resp.result["id"]
            @password=resp.result["password"]
            true
        end

      else
        raise IncompleteCustomer
      end
    end

    def download_list(auth)
      client=ImOrder::Client.new("https://#{ImOrder::Client.domain}/fr/web_service/customer_download_list")
      parameters=auth.to_params
      parameters["customer_uid"]=@uid
      resp=client.request(parameters)
      case resp
        when ResponseError
          @error=resp
          raise resp.exception, resp.message
        when ResponseWarning
          @warning=resp
          false
        when Response
          @downloads=to_downloads(resp)
          true
      end
    end

  end
end