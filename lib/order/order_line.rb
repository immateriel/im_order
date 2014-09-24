module ImOrder
  class OrderLine
    attr_accessor :ean
    def initialize(ean,price,currency,qty=1)
      @ean=ean
      @price=price
      @currency=currency
      @qty=qty
    end

    def to_params
      {"price"=>@price,"currency"=>@currency,"qty"=>@qty}
    end

  end
end