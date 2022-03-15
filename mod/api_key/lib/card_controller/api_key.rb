class CardController
  # add support for passing api key through header using X-API-Key
  module ApiKey
    def authenticators
      return {} unless request

      super.merge api_key: api_key_from_header || params[:api_key]
    end

    def api_key_from_header
      request.headers["X-API-Key"]
    end
  end
end
