RSpec.describe Card::Set::Abstract::Search::Views do
  def card_subject
    :search.card
  end
  check_views_for_errors format: :json
  check_views_for_errors format: :data
  check_views_for_errors format: :html
end
