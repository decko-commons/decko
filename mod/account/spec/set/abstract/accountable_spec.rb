RSpec.describe Card::Set::Abstract::Accountable do
  def card_subject
    Card["Joe User"]
  end

  check_views_for_errors
end
