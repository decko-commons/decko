# -*- encoding : utf-8 -*-

# rubocop:disable Lint/AmbiguousRegexpLiteral

When /^(?:|I )enter "([^"]*)" into "([^"]*)"$/ do |value, field|
  selector = ".RIGHT-#{field.to_name.safe_key} input.d0-card-content"
  find(selector).set value
end

When /^(?:|I )enter "([^"]*)" into "([^"]*)" in modal$/ do |value, field|
  selector = ".modal .RIGHT-#{field.to_name.safe_key} input.d0-card-content"
  find(selector).set value
end

When /^In (.*) I follow "([^"]*)"$/ do |section, link|
  within scope_of(section) do
    click_link link
  end
end

When /^In (.*) I click "(.*)"$/ do |section, link|
  within scope_of(section) do
    click_link link
  end
end

When /^I click "(.*)" within "(.*)"$/ do |link, selector|
  within selector do
    click_link link
  end
end

When /^In (.*) I find link with class "(.*)" and click it$/ do |section, css_class|
  within scope_of(section) do
    find("a.#{css_class}").click
  end
end

When /^In (.*) I find link with icon "(.*)" and click it$/ do |section, icon|
  within scope_of(section) do
    find("a > i.material-icons", text: icon).click
  end
end

When /^In (.*) I find button with icon "(.*)" and click it$/ do |section, icon|
  within scope_of(section) do
    find("button > i.material-icons", text: icon).click
  end
end

Then /I submit$/ do
  click_button "Save and Close"
end

When /^I open the main card menu$/ do
  slot = "$('#main .menu-slot .vertical-card-menu._show-on-hover .card-slot')"
  page.execute_script "#{slot}.show()"
  page.find("#main .menu-slot .card-menu a").click
end

When /^I close the modal window$/ do
  page.find("._modal-menu ._close-modal").click
end

When /^I fill in "([^"]*)" with$/ do |field, value|
  fill_in(field, with: value)
end

When(/^I scroll (-?\d+) pixels$/) do |number|
  page.execute_script "window.scrollBy(0, #{number})"
end

When(/^I scroll (\d+) pixels down$/) do |number|
  page.execute_script "window.scrollBy(0, #{number})"
end

When(/^I scroll (\d+) pixels up$/) do |number|
  page.execute_script "window.scrollBy(0, -#{number})"
end

module Capybara
  module Node
    # adapt capybara methods to fill in forms to decko's form interface
    module Actions
      alias_method :original_fill_in, :fill_in
      alias_method :original_select, :select

      def fill_in(locator, with: nil, **)
        decko_fill_in(locator, with) || original_fill_in(locator, with: with, **)
      end

      def select(value, from: nil, **)
        decko_select(value, from) || original_select(value, from: from, **)
      end

      def decko_fill_in locator, with
        el = labeled_field(:input, locator) || labeled_field(:textarea, locator)
        return unless el

        el.set with
        true
      end

      def decko_select value, from
        el = labeled_field :select, from, visible: false
        return unless el

        value = el.find("option", text: value, visible: false)["value"]
        choose_value el, value
        true
      end

      def choose_value el, value
        id = el["id"]
        session.execute_script("$('##{id}').val('#{value}')")
        # session.execute_script("$('##{id}').trigger('chosen:updated')")
        # session.execute_script("$('##{id}').change()")
      end

      def labeled_field type, label, visible: true
        label.gsub!(/^\+/, "") # because '+' is in an extra span,
        # descendant-or-self::text doesn't find it
        first :xpath,
              "//label[descendant-or-self::text()='#{label}']/..//#{type}",
              visible: visible, wait: 5, minimum: 0
      end
    end
  end
end
