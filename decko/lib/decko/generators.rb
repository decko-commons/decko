# -*- encoding : utf-8 -*-

require "cardio/generators/class_methods"

module Decko
  module Generators
    # noop
  end
end

module Cardio
  module Generators
    module ClassMethods
      # generator USAGE docs will use "decko" rather than "card" when called with decko
      def banner_command
        "decko"
      end
    end
  end
end
