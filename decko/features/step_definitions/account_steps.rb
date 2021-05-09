# -*- encoding : utf-8 -*-

# rubocop:disable Lint/AmbiguousRegexpLiteral

# Given /^I sign in as (.+)$/ do |account_name|
#   # FIXME: define a faster simulate method ("I am logged in as")
#   accounted = Card[account_name]
#   @current_id = accounted.id
#   visit "/:signin"
#   fill_in "card[subcards][+*email][content]", with: accounted.account.email
#   fill_in "card[subcards][+*password][content]", with: 'joe_pass'
#   click_button "Sign in"
#   page.should have_content(account_name)
# end

Given /^I am signed in as (.+)$/ do |account_name|
  accounted = Card[account_name]
  visit "/update/:signin?card[subcards][%2B*email][content]="\
    "#{accounted.account.email}&card[subcards][%2B*password][content]=joe_pass"
  # could optimize by specifying simple text success page
end

Given /^I am signed out$/ do
  visit "/"
  click_link("Sign out") if page.has_content? "Sign out"
end

Then /^"([^"]*)" should be signed in$/ do |user| # "
  has_css?(".my-card-link", text: user)
end
