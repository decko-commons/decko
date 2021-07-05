class CardController
  module ApiKey
    def authenticators
      super.merge api_key: api_key_from_header || params[:api_key]
    end

    def api_key_from_header
      request.headers["X-API-Key"]
    end
  end
end
