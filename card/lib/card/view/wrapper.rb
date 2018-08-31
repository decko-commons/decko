class Card
  class View
    # method to render views with layouts
    module Wrapper
      def with_wrapper &render_block
        if layout.present?
          wrap ||= []
          wrap.push layout.to_name.key
        end

        @rendered = render_block.call
        return @rendered unless wrap.present?
        wrap.reverse.each do |wrapper|
          @rendered =
            format.try("wrap_with_#{wrapper}") { @rendered } ||
              Card::Layout::CardLayout.new(wrapper, format).render
        end
        @rendered
      end
    end
  end
end
