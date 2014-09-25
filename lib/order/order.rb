require 'order/client'
require 'order/auth'
require 'order/customer'
require 'order/order_line'
require 'order/download'

module ImOrder
  class IncompleteOrder < StandardError
  end

  class Order
    include DownloadList
    attr_accessor :uid, :id, :amount, :tax, :download_key, :downloads, :error, :warning

    def initialize(uid, customer=nil, order_lines=nil)
      @uid=uid
      @customer=customer
      @order_lines=order_lines

      @id=nil
      @amount=nil
      @tax=nil
      @download_key=nil
      @error=nil
      @warning=nil
      @downloads=nil
    end

    def to_params
      {"order_uid" => @uid, "customer_uid" => @customer.uid}
    end

    def push(auth)
      if @customer and @order_lines and @order_lines.length > 0
        client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/push_order")
        parameters=auth.to_params
        parameters=parameters.merge(self.to_params)
        parameters["order_lines"]={}
        @order_lines.each do |ol|
          parameters["order_lines"][ol.ean]=ol.to_params
        end
        resp=client.request(parameters)

        if resp.type=="Error"
          @error=resp
          false
        else
          if resp.type=="Warning"
            @warning=resp
            @id=resp.result["id"]
            false
          else
            @id=resp.result["id"]
            @amount=resp.result["amount"]
            @tax=resp.result["tax"]
            @download_key=resp.result["download_key"]
            true
          end
        end

      else
        raise IncompleteOrder
      end
    end

    def download_list(auth)
      client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/order_download_list")
      parameters=auth.to_params
      parameters["order_uid"]=@uid
      resp=client.request(parameters)
      if resp.type=="Error"
        @error=resp
        false
      else
        if resp.type=="Warning"
          @warning=resp
          false
        else
          @downloads=to_downloads(resp)
          true
        end
      end
    end

  end
end