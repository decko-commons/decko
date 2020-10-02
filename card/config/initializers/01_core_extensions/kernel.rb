warn "core extension 3"
module CoreExtensions
  module Kernel
    def suppress_warnings
      original_verbosity = $VERBOSE
      $VERBOSE = nil
      yield
    ensure
      $VERBOSE = original_verbosity
    end
  end
end
