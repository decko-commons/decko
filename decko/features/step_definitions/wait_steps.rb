# -*- encoding : utf-8 -*-

# rubocop:disable Lint/AmbiguousRegexpLiteral

When /I wait a sec/ do
  sleep 1
end

When /I wait (\d+) seconds?$/ do |period|
  sleep period.to_i
end

def wait_for_ajax
  Timeout.timeout(Capybara.default_max_wait_time) do
    sleep(0.5) until finished_all_ajax_requests?
  end
end

def finished_all_ajax_requests?
  jquery_undefined? || page.evaluate_script("jQuery.active").zero?
end

def jquery_undefined?
  page.evaluate_script("typeof(jQuery) === 'undefined'")
end

When /^I wait for ajax response$/ do
  wait_for_ajax
end
