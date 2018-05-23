When(/^I enter "([^"]*)" in the navbox$/) do |arg|
  enter_select2(arg, ".navbox-form")
end

When(/^I enter '([^']*)' in the navbox$/) do |arg|
  enter_select2(arg, ".navbox-form")
  wait_for_ajax # wait for search results
end

When(/^I search for "([^"]*)" using the navbox$/) do |arg|
  enter_and_select_select2(arg, ".navbox-form")
end

When(/^(?:|I )select2 "([^"]*)" from "([^"]*)"$/) do |value, field|
  select_from_select2(value, from: field)
end

def select_from_select2 value, attrs
  find("[name='#{attrs[:from]}'] + .select2-container").click
  list = find(:xpath, '//span[@class="select2-results"]', visible: :all)
  list.find("li", text: value).click
end

def enter_select2 value, css
  select2_container = find(:css, css)
  sleep 0.1
  @container = select2_container.find(".select2-selection, .select2-choices", visible: false)
  @container.click
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
