# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Set::HtmlViews do
  def card_subject
    Card.fetch("User+*type")
  end

  check_html_views_for_errors
end
