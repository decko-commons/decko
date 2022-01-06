class Card
  module Env
    # slot-related environmental variable handling
    module SlotOptions
      def slot_opts
        # FIXME:  upgrade to safe parameters
        @slot_opts ||= interpret_slot_options
      end

      private

      def interpret_slot_options
        opts = hash params[:slot]
        opts.merge! shortcut_slot_opts
        opts.deep_symbolize_keys.slice(*Card::View::Options.slot_keys)
      end

      def shortcut_slot_opts
        opts = {}
        opts[:size] = params[:size].to_sym if params[:size]
        opts[:items] = { view: params[:item].to_sym } if slot_items_shortcut?
        opts
      end

      def slot_items_shortcut?
        params[:item].present? && !params.dig(:slot, :items, :view).present?
      end
    end
  end
end
