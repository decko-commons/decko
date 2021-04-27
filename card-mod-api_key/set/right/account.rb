card_accessor :api_key

def validate_api_key! api_key
  api_key_card.validate! api_key
end
