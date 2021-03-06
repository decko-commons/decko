# -*- encoding : utf-8 -*-

require "rails/generators"
require "rails/generators/active_record"

module Cardio
  # for now, this just fulfills zeitwerk expectations. File is here for require calls.
  module Generators
    # noop
  end
end

module Rails
  # override to hide all the rails generators that don't apply in a card/decko context
  module Generators
    def self.sorted_groups
      [["card", %w[mod set migration]]]
    end
  end
end
