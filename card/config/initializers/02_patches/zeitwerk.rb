module Patches
  module Zeitwerk
    def reload
      super
      if reloading_enabled?
        # reloading the Card class triggers also ::Card::Mod.load
        # via the after_card hook
        ::Card
        # ::Card::Mod.load
      end
    end
  end
end
