class Card
  class ActManager
    class StageDirector
      # Special handling specific to the :store stage
      module Store
        # The tricky part here is to preserve the dirty marks on the subcards'
        # attributes for the finalize stage.
        # To achieve this we can't just call the :store and :finalize callbacks on
        # the subcards as we do in the other phases.
        # Instead we have to call `save` on the subcards
        # and use the ActiveRecord :around_save callback to run the :store and
        # :finalize stages
        def store &save_block
          raise Card::Error, "need block to store main card" if main? && !block_given?

          # the block is the ActiveRecord block from the around save callback that
          # saves the card
          if block_given?
            run_stage_callbacks :store
            store_with_subcards(&save_block)
          else
            trigger_storage_phase_callback
          end
        end

        def store_with_subcards
          store_pre_subcards
          yield
          @call_after_store.each { |handle_id| handle_id.call(@card.id) }
          store_post_subcards
          true.tap { @virtual = false } # TODO: find a better place for this
        ensure
          @card.handle_subcard_errors
        end

        # store subcards whose ids we need for this card
        def store_pre_subcards
          run_subdirector_stages :store, &:prioritize
        end

        def store_post_subcards
          run_subdirector_stages(:store) { |subdir| !subdir.prioritize }
        end

        # trigger the storage_phase, skip the other phases
        # At this point the :prepare_to_store stage was already executed
        # by the parent director. So the storage phase will only run
        # the :store stage and the :finalize stage
        def trigger_storage_phase_callback
          @stage = stage_index :prepare_to_store
          @card.save_as_subcard!
        end
      end
    end
  end
end
