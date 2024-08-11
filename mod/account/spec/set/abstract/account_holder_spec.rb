RSpec.describe Card::Set::Abstract::AccountHolder do
  def card_subject
    Card["Joe User"]
  end

  check_views_for_errors
end
