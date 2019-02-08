# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Rule::Editor do
  def card_subject
    Card.fetch("*read+*right+*input", new: {})
  end

  check_html_views_for_errors
end
