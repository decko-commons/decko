# -*- encoding : utf-8 -*-

# rubocop:disable Lint/AmbiguousRegexpLiteral
#
Then /the card (.*) should contain "([^"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("main card content") do
    expect(page).to have_content(content)
  end
end

Then /the card (.*) should not contain "([^"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("main card content") do
    expect(page).not_to have_content(content)
  end
end

Then /the card (.*) should point to "([^"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("pointer card content") do
    expect(page).to have_content(content)
  end
end

Then /the card (.*) should not point to "([^"]*)"$/ do |cardname, content|
  visit path_to("card #{cardname}")
  within scope_of("pointer card content") do
    expect(page).not_to have_content(content)
  end
end

Then /^In (.*) I should see "([^"]*)"$/ do |section, text|
  within scope_of(section) do
    if text.index("|")
      expect(text.split("|").any? { |t| have_content(t) }).to be
    else
      expect(page).to have_content(text)
    end
  end
end

Then /^I should see "([^"]*)" in the editor$/ do |text|
  within_frame 0 do
    expect(page).to have_content(text)
  end
end

Then /^In (.*) I should not see "([^"]*)"$/ do |section, text|
  within scope_of(section) do
    expect(page).not_to have_content(text)
  end
end

Then /^In (.*) I should (not )?see a ([^"]*) with class "([^"]*)"$/ do |selection, neg, element, selector|
  # checks for existence of a element with a class in a selection context
  element = "a" if element == "link"
  within scope_of(selection) do
    verb = neg ? :should_not : :should
    page.send(verb, have_css([element, selector].join(".")))
  end
end

Then /^In (.*) I should (not )?see a ([^"]*) with content "([^"]*)"$/ do |selection, neg, element, content|
  # checks for existence of a element with a class in a selection context
  element = "a" if element == "link"
  within scope_of(selection) do
    verb = neg ? :should_not : :should
    page.send(verb, have_css(element, text: content))
  end
end

Then /^the "([^"]*)" field should contain "([^"]*)"$/ do |field, value|
  expect(field_labeled(field).value).to match(/#{value}/)
end

Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |value, field|
  element = field_labeled(field).element
  selected = element.search ".//option[@selected = 'selected']"
  expect(selected.inner_html).to match /#{value}/
end

Then /^I should see css class "([^"]*)" within "(.*)"$/ do |css_class, selector|
  within selector do
    find(css_class)
  end
end

## variants of standard steps to handle """ style quoted args
Then /^I should see$/ do |text|
  expect(page).to have_content(text)
end

Then /^I should see "([^"]*)" in color (.*)$/ do |text, css_class|
  page.has_css?(".diff-#{css_class}", text: text)
end

Then /^I should see css class "([^"]*)"$/ do |css_class|
  find(css_class)
end
