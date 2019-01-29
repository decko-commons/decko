RSpec::Matchers.define :lack_errors do
  match do |view|
    view !~ /(?<![-\w])(error|not supported)(?![-\w])/i
  end

  failure_message do |view|
    %(View #{view} contains either "error" or "not supported")
  end
end
