module ImOrder
  class OrderLine
    attr_accessor :ean
    def initialize(ean,price,currency,qty=1,special_code=nil)
      @ean=ean
      @price=price
      @currency=currency
      @qty=qty
      @special_code=special_code
    end

    def to_params
      params={"price"=>@price,"currency"=>@currency,"qty"=>@qty}

      if special_code
        params["special_code"]=@special_code
      end

      params
    end

  end
end