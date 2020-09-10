class Card
  before_validation :validation_phase, if: -> { validation_phase_callback? }
  around_save :storage_phase
  after_commit :integration_phase, if: -> { integration_phase_callback? }

  class Director
    # Validation, Storage, and Integration phase handling
    module Phases
      def validation_phase_callback?
        !@only_storage_phase && head?
      end

      def integration_phase_callback?
        !@only_storage_phase && main?
      end

      def prepare_for_phases
        @card.prepare_for_phases unless running?
        @running = true
        @subdirectors.each(&:prepare_for_phases)
      end

      def validation_phase
        run_stage :initialize
        run_stage :prepare_to_validate
        run_stage :validate
      ensure
        # @card.expire_pieces if @card.errors.any?
        @card.errors.empty?
      end

      # Unlike other phases, the storage phase takes a block,
      # because it is called by an "around" callback
      def storage_phase &block
        catch_up_to_stage :prepare_to_store
        run_stage :store, &block
        run_stage :finalize
        raise ActiveRecord::RecordInvalid, @card if @card.errors.any?
      ensure
        @from_trash = nil
      end

      def integration_phase
        return if @abort

        @card.restore_changes_information
        run_stage :integrate
        run_stage :after_integrate
        run_stage :integrate_with_delay
      ensure
        @card.clear_changes_information unless @abort
      end
    end
  end
end
