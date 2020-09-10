class Card
  class Director
    module CardMethods
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

      def restore_changes_information
        # restores changes for integration phase
        # (rails cleared them in an after_create/after_update hook which is
        #  executed before the integration phase)
        return unless saved_changes.present?

        @mutations_from_database = mutations_before_last_save
      end
    end
  end
end
