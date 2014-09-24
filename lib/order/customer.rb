require 'net/http'
require 'net/https'
require 'nokogiri'

module ImOrder
  class IncompleteCustomer < StandardError
  end
  class Customer
    attr_accessor :uid

    def initialize(uid, email=nil, firstname=nil, lastname=nil, country=nil)
      @uid=uid
      @email=email
      @firstname=firstname
      @lastname=lastname
      @country=country
    end

    def to_params
      {"customer_uid" => @uid, "email" => @email, "firstname" => @firstname, "lastname" => @lastname, "country" => @country}
    end

    def push(auth)
      if @email and @firstname and @lastname and @country
        client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/push_customer")

        parameters=auth.to_params
        parameters=parameters.merge(self.to_params)

        client.request(parameters)
      else
        raise IncompleteCustomer
      end
    end

    def download_list(auth)
      client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/customer_download_list")
      parameters=auth.to_params
      parameters["customer_uid"]=@uid
      client.request(parameters)
    end

  end
end