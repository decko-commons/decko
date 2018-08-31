class Card
  class View
    # method to render views with layouts
    module Layout
      def with_layout &render_block
        return render_block.call unless layout.present?
        format.rendered_main_nest = format.wrap_main(&render_block)
        ::Card::Layout.render layout, self
      end
    end
  end
end
