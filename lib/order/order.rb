require 'order/client'
require 'order/auth'
require 'order/customer'
require 'order/order_line'

module ImOrder
  class IncompleteOrder < StandardError
  end

  class Order
    attr_accessor :uid

    def initialize(uid, customer=nil, order_lines=nil)
      @uid=uid
      @customer=customer
      @order_lines=order_lines
    end

    def to_params
      {"order_uid" => @uid, "customer_uid" => @customer.uid}
    end

    def push(auth)
      if @customer and @order_lines.length > 0
        client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/push_order")
        parameters=auth.to_params
        parameters=parameters.merge(self.to_params)
        parameters["order_lines"]={}
        @order_lines.each do |ol|
          parameters["order_lines"][ol.ean]=ol.to_params
        end
        client.request(parameters)
      else
        raise IncompleteOrder
      end
    end

    def download_list(auth)
      client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/order_download_list")
      parameters=auth.to_params
      parameters["order_uid"]=@uid
      client.request(parameters)
    end

  end
end