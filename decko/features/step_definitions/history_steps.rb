# -*- encoding : utf-8 -*-

# rubocop:disable Lint/AmbiguousRegexpLiteral
When /^I expand act (\d+)$/ do |index|
  all('.panel-heading[data-bs-toggle="collapse"]')[-index.to_i].click
end
