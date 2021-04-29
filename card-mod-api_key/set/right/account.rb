card_accessor :api_key

delegate :authenticate_api_key, to: :api_key_card
