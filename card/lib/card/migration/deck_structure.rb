# -*- encoding : utf-8 -*-
require "card/migration"

class Card
  class Migration
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
