RSpec::Matchers.define :lack_errors do
  match do |view|
    view !~ /(error|not supported)/i
  end

  failure_message do |view|
    %(View #{view} contains either "error" or "not supported")
  end
end