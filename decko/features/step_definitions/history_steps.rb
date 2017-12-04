# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral, Lint/Syntax
When /^I expand act (\d+)$/ do |index|
  all('.panel-heading[data-toggle="collapse"]')[-index.to_i].click
end
