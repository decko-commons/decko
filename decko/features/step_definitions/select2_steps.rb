When(/^I enter "([^"]*)" in the search box$/) do |arg|
  enter_select2(arg, ".search-box-form")
end

When(/^I enter '([^']*)' in the search box$/) do |arg|
  enter_select2(arg, ".search-box-form")
  wait_for_ajax # wait for search results
end

When(/^I search for "([^"]*)" using the search box$/) do |arg|
  enter_and_select_select2(arg, ".search-box-form")
end

When(/^(?:|I )select2 "([^"]*)" from "([^"]*)"$/) do |value, field|
  select_from_select2(value, from: field)
end

def select_from_select2 value, attrs
  find("[name='#{attrs[:from]}'] + .select2-container").click
  list = find(:xpath, '//span[@class="select2-results"]', visible: :all)
  list.find("li", text: value).click
end

def open_select2 css
  select2_container = find(:css, css)
  sleep 0.1
  @container = select2_container.find(".select2-selection, .select2-choices", visible: false)
  @container.click
end

def enter_select2 value, css
  open_select2 css
  find(:xpath, "//body").find(".select2-search input.select2-search__field").set(value)
end

def enter_and_select_select2 value, css
  enter_select2 value, css
  find(:xpath, "//body").find(".select2-results li.select2-results__option", text: value).click
end

When(/^I press enter to search$/) do
  @container.native.send_keys(:return)
  wait_for_ajax
  # find("#query_keyword").native.send_keys(:return)
end
