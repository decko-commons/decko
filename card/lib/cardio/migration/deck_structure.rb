# -*- encoding : utf-8 -*-

# ENV["NO_CARD_LOAD"] = "true"

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
