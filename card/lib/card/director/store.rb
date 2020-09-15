class Card
  class Director
    # Special handling specific to the :store stage
    module Store
      def after_store &block
        @after_store ||= []
        @after_store << block
      end

      protected

      def after_store?
        @after_store.present?
      end

      private

      # The tricky part here is to preserve the dirty marks on the subcards'
      # attributes for the finalize stage.
      # To achieve this we can't just call the :store and :finalize callbacks on
      # the subcards as we do in the other phases.
      # Instead we have to call `save` on the subcards and use the ActiveRecord
      # :around_save callback.
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
        store_pre_subcards # the exception!  usually does nothing
        yield
        run_after_store_callbacks if after_store?
        store_post_subcards # the typical case
        true
      ensure
        @card.handle_subcard_errors
      end

      def run_after_store_callbacks
        @after_store.each { |block| block.call @card }
      end

      # If the subcard has an after-store callback, it means the subcard
      # must run before the supercard and then call back
      def store_pre_subcards
        run_subcard_stages :store, &:after_store?
      end

      def store_post_subcards
        run_subcard_stages(:store) { |subdir| !subdir.after_store? }
      end

      # trigger the storage_phase, skip the other phases
      # At this point the :prepare_to_store stage was already executed
      # by the parent director. So the storage phase will only run
      # the :store stage and the :finalize stage
      def trigger_storage_phase_callback
        @stage = stage_index :prepare_to_store
        @only_storage_phase = true
        @card.save! validate: false, as_subcard: true
      end
    end
  end
end
