# -*- encoding : utf-8 -*-

require "cardio/generators/class_methods"

module Cardio
  module Generators
    # main definition of this module is in card gem
    module ClassMethods
      # generator USAGE docs will use "decko" rather than "card" when called with decko
      def banner_command
        "decko"
      end
    end
  end
end
