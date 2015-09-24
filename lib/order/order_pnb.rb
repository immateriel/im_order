require 'order/client'
require 'order/auth'
require 'order/customer'
require 'order/order_line'
require 'order/download'
require 'order/error'

module ImOrder

  class OrderPnb
    include DownloadList
    attr_accessor :uid, :id, :amount, :tax, :download_key, :voidable, :error, :warning

    def initialize(uid, order_lines=nil)
      @uid=uid
      @order_lines=order_lines

      @id=nil
      @amount=nil
      @tax=nil
      @download_key=nil
      @error=nil
      @warning=nil
    end

    def to_params
      {"order_uid" => @uid}
    end

    def push(auth)
      if @customer and @order_lines and @order_lines.length > 0
        client=ImOrder::Client.new("https://ws.immateriel.fr/fr/web_service/push_order_pnb")
        parameters=auth.to_params
        parameters=parameters.merge(self.to_params)
        parameters["order_lines"]={}
        @order_lines.each do |ol|
          parameters["order_lines"][ol.ean]=ol.to_params
        end
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
            @amount=resp.result["amount"]
            @tax=resp.result["tax"]
            @download_key=resp.result["download_key"]
            true
        end
      else
        raise IncompleteOrder
      end
    end

  end
end