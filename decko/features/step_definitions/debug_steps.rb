# -*- encoding : utf-8 -*-
# rubocop:disable Lint/AmbiguousRegexpLiteral, Lint/Syntax

Then /debug/ do
  require "pry"
  binding.pry #
  nil
end

Then /what/ do
  save_and_open_page
end

Then /^No errors in the job queue$/ do
  if (last_error = Delayed::Job.last&.last_error)
    puts last_error
    expect(last_error).to be_blank
  end
end
