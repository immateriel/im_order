module ImOrder
  class OrderLinePnb
    include DownloadList
    attr_accessor :ean,:downloads,:status
    def initialize(order_line_uid,ean=nil,price=nil,currency=nil,qty=1,special_code=nil)
      @ean=ean
      @price=price
      @currency=currency
      @order_line_uid=order_line_uid
      @qty=qty
      @special_code=special_code
      @downloads=nil
      @status={}
    end

    def to_params
      params={"price"=>@price,"currency"=>@currency,"order_line_uid"=>@order_line_uid,"qty"=>@qty}

      if @special_code
        params["special_code"]=@special_code
      end

      params
    end

    def push_loan(auth,loan_uid,medium="download")
      client=ImOrder::Client.new("https://#{ImOrder::Client.domain}/fr/web_service/push_loan_pnb")
      parameters=auth.to_params
      parameters["order_line_uid"]=@order_line_uid
      parameters["loan_uid"]=loan_uid
      parameters["medium"]=medium
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

    # take only one line, OK for testing purpose
    def get_status(auth)
      client=ImOrder::Client.new("https://#{ImOrder::Client.domain}/fr/web_service/get_order_pnb")
      parameters=auth.to_params
      parameters["order_line_uids"]=@order_line_uid
      resp=client.request(parameters)
      case resp
        when ResponseError
          @error=resp
          raise resp.exception, resp.message
        when ResponseWarning
          @warning=resp
          false
        when Response
          pp resp
          resp.result.children.each do |pr|
            if pr.element? and pr["order_line_uid"]==@order_line_uid
              @status[:total_loans]=pr["total_loans"].to_i
              @status[:current_loans]=pr["current_loans"].to_i
            end
          end
          true
      end
    end

  end
end