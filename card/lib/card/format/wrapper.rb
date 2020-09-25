class Card
  class Format
    module Wrapper
      def with_wrapper
        if voo.layout.present?
          voo.wrap ||= []
          layout = voo.layout.to_name.key
          # don't wrap twice with modals or overlays
          # this can happen if the view is wrapped with modal
          # and is requested with layout=modal param
          voo.wrap.unshift layout unless voo.wrap.include? layout.to_sym
        end

        @rendered = yield
        wrap_with_wrapper
      end

      def wrap_with_wrapper
        return @rendered unless voo.wrap.present?

        voo.wrap.reverse.each do |wrapper, opts|
          @rendered =
            render_with_wrapper(wrapper, opts) ||
            render_with_card_layout(wrapper) ||
            raise_wrap_error(wrapper)
        end
        @rendered
      end

      def render_with_wrapper wrapper, opts
        try("wrap_with_#{wrapper}", opts) { @rendered }
      end

      def render_with_card_layout mark
        return unless Card::Layout.card_layout? mark

        Card::Layout::CardLayout.new(mark, self).render
      end

      def raise_wrap_error wrapper
        if wrapper.is_a? String
          raise Card::Error::UserError, "unknown layout card: #{wrapper}"
        else
          raise ArgumentError, "unknown wrapper: #{wrapper}"
        end
      end
    end
  end
end