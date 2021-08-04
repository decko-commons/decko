# -*- encoding : utf-8 -*-

require "cardio/migration"

module Cardio
  class Migration
    # Inherit from this migration class to make database table changes
    # in your deck
    class DeckStructure < Migration
      @type = :deck

      def contentedly &block
        Schema.mode :deck, &block
      end
    end
  end
end
