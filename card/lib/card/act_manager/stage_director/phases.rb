class Card
  class ActManager
    class StageDirector
      module Phases
        def validation_phase
          run_single_stage :initialize
          run_single_stage :prepare_to_validate
          run_single_stage :validate
          @card.expire_pieces if @card.errors.any?
          @card.errors.empty?
        end

        def storage_phase &block
          catch_up_to_stage :prepare_to_store
          run_single_stage :store, &block
          run_single_stage :finalize
          if @card.errors.any?
            @card.expire_pieces
            raise ActiveRecord::Rollback,
                  "errors added in storage phase: #{@card.errors.full_messages * ','}"
          end
        ensure
          @from_trash = nil
        end

        def integration_phase
          return if @abort

          @card.restore_changes_information
          run_single_stage :integrate
          run_single_stage :after_integrate
          run_single_stage :integrate_with_delay
        ensure
          @card.clear_changes_information unless @abort
          # ActManager.clear if main? && !@card.only_storage_phase
        end
      end
    end
  end
end
