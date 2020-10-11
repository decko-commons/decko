# -*- encoding : utf-8 -*-

require "cardio/migration"

module Cardio
  class Migration
    # Inherit from this migration class to make database table changes
    # in your deck
    class DeckStructure < Migration
      @type = :deck

      def contentedly
        Cardio.schema_mode :deck do
          yield
        end
      end
    end
  end
end
