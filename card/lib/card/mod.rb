require_dependency "card/mod/loader"
require_dependency "card/mod/dirs"


class Card
  module Mod
    class << self
      def load
        Loader.load_mods
      end

      # @return an array of Rails::Path objects
      def dirs
        @dirs ||= Dirs.new(Card.paths["mod"].existent)
      end
    end
  end
end