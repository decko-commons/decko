class Card
  class View
    # method to render views with layouts
    module Wrapper
      def with_wrapper &render_block
        if layout.present?
          self.wrap ||= []
          wrap.push layout.to_name.key
        end

        format.rendered = render_block.call
        return format.rendered unless wrap.present?
        wrap.reverse.each do |wrapper|
          format.rendered =
            format.try("wrap_with_#{wrapper}") { format.rendered } ||
              Card::Layout::CardLayout.new(wrapper, format).render
        end
        format.rendered
      end
    end
  end
end
