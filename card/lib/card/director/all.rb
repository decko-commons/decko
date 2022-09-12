class Card
  class Director
    # director-related Card instance methods
    module All
      attr_writer :director

      delegate :validation_phase, :storage_phase, :integration_phase,
               :validation_phase_callback?, :integration_phase_callback?, to: :director

      def director
        @director ||= Director.fetch self
      end

      def prepare_for_phases
        reset_patterns
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

      def act options={}, &block
        @subcards = nil
        if act_card
          add_to_act options, &block
        else
          start_new_act(&block)
        end
      end

      def act_card
        Card::Director.act_card
      end

      def act_card?
        self == act_card
      end

      def save! **args
        as_subcard = args.delete :as_subcard
        act(as_subcard: as_subcard) { super **args }
      end

      def save *_args
        act { super }
      end

      def valid? *_args
        act(validating: true) { super }
      end

      def update *_args
        act { super }
      end

      def update! *_args
        act { super }
      end

      alias_method :update_attributes, :update
      alias_method :update_attributes!, :update!

      def restore_changes_information
        # restores changes for integration phase
        # (rails cleared them in an after_create/after_update hook which is
        #  executed before the integration phase)
        return unless saved_changes.present?

        @mutations_from_database = mutations_before_last_save
      end

      def clear_action_specific_attributes
        self.class.action_specific_attributes.each do |attr|
          instance_variable_set "@#{attr}", nil
        end
      end

      private

      def start_new_act &block
        self.director = nil
        Director.run_act(self) do
          run_callbacks(:act, &block)
        end
      end

      def add_to_act options={}
        director.appoint self unless @director
        director.head = true unless options[:validating] || options[:as_subcard]
        yield
      end
    end
  end
end
