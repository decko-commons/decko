card_accessor :api_key

delegate :authenticate_api_key, to: :api_key_card

format :html do
  view :api_key do
    field_nest :api_key
  end
end
