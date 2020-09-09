class Card
  module Direction
    attr_writer :director
    delegate :validation_phase, :storage_phase, :integration_phase,
             :validation_phase_callback?, :integration_phase_callback?, to: :director

    def director
      @director ||= Director.fetch self
    end

    def prepare_for_phases
      reset_patterns
      identify_action
      include_set_modules
    end

    def identify_action
      @action =
        if trash && trash_changed?
          :delete
        elsif new_card?
          :create
        else
          :update
        end
    end
  end
end
