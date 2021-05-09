# -*- encoding : utf-8 -*-

# rubocop:disable Lint/AmbiguousRegexpLiteral

When /^(?:|I )upload the (.+) "(.+)"$/ do |attachment_name, filename|
  Capybara.ignore_hidden_elements = false
  attach_file "card_#{attachment_name}", find_file(filename)
  Capybara.ignore_hidden_elements = true
  wait_for_ajax
end

def find_file filename
  roots = "{#{Cardio.root}/mod/**,#{Cardio.gem_root}/mod/**,#{Decko.gem_root}}"
  paths = Dir.glob(File.join(roots, "features", "support", filename))
  raise ArgumentError, "couldn't find file '#{filename}'" if paths.empty?

  paths.first
end

Then /^I should see a preview image of size (.+)$/ do |size|
  find("span.preview img[src*='#{size}.png']")
end

Then /^I should see an image of size "(.+)" and type "(.+)"$/ do |size, type|
  find("img[src*='#{size}.#{type}']")
end

Then /^within "(.+)" I should see an image of size "(.+)" and type "(.+)"$/ do |selector, size, type|
  within selector do
    find("img[src*='#{size}.#{type}']")
  end
end

Then /^I should see a non-coded image of size "(.+)" and type "(.+)"$/ do |size, type|
  element = find("img[src*='#{size}.#{type}']")
  expect(element[:src]).to match(%r{/~\d+/})
end

# Adds support for validates_attachment_content_type.
# Without the mime-type getting passed to attach_file() you will get a
# "Photo file is not one of the allowed file types."
# error message
When /^(?:|I )attach the file "([^"]*)" to "([^"]*)"$/ do |path, field|
  type = path.split(".")[1]

  case type
  when "jpg"
    type = "image/jpg"
  when "jpeg"
    type = "image/jpeg"
  when "png"
    type = "image/png"
  when "gif"
    type = "image/gif"
  end

  attach_file(field, path, type)
end
