require "byebug"

Then /debug/ do
  require "pry"
  binding.pry #
  nil
end

Then /what/ do
  save_and_open_page
end

Then /^No errors in the job queue$/ do
  if (last = Delayed::Job.last) && (last.last_error)
    puts last.last_error
    expect(last.last_error).to be_blank
  end
end
