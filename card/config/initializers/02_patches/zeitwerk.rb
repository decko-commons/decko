module Patches
  module Zeitwerk
    def reload
      super
      return unless reloading_enabled?

      # reloading the Card class triggers also ::Cardio::Mod.load
      # via the after_card hook
      ::Card
      # ::Cardio::Mod.load
    end
  end
end
