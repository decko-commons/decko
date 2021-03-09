RSpec::Matchers.define :lack_errors do
  match do |view|
    view !~ /(?<![-\w])(error|not supported|translation missing)(?![-\w])/i
  end

  failure_message do |view|
    %(View #{view} contains "error", "not supported", or "translation missing")
  end
end
