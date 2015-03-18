module ImOrder
  class InvalidKey < StandardError
  end

  class UnknownReseller < StandardError
  end

  class Forbidden < StandardError
  end

  class DataInvalid < StandardError
  end

  class DataMissing < StandardError
  end

  class UnknownCustomer < StandardError
  end

  class UnknownOrder < StandardError
  end

  class SellInvalidPrice < StandardError
  end

  class SellForbidden < StandardError
  end

  class InternalError < StandardError
  end
  ###

  class IncompleteCustomer < StandardError
  end

  class IncompleteOrder < StandardError
  end


end