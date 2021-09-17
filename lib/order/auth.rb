module ImOrder

  class Auth
    def initialize(api_key, reseller_id = nil, reseller_gencod = nil)
      @api_key = api_key
      @reseller_id = reseller_id
      @reseller_gencod = reseller_gencod
    end

    def to_params
      params = { "api_key" => @api_key }
      if @reseller_id
        params["reseller_id"] = @reseller_id
      else
        if @reseller_gencod
          params["reseller_dilicom_gencod"] = @reseller_gencod
        end
      end
      params
    end
  end
end