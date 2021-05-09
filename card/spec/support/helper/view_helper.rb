class Card
  module SpecHelper
    # helper for card views in specs
    module ViewHelper
      def expect_view view_name, format: :html, card: nil
        if card
          # view()
          v = view(view_name, card: card, format: format)
          expect(v)
        else
          expect(format_subject(format).render(view_name))
        end
      end

      def view view_name, card: { name: "test card", type: :basic }, format: :html
        render_card_with_args view_name, card, format: format
      end

      def render_input type
        card = Card.create(name: "my favority #{type} + #{rand(4)}", type: type)
        card.format.render!(:edit)
      end

      def render_content content, format_args={}
        @card ||= Card.new name: "Tempo Rary 2"
        @card.content = content
        @card.format(format_args)._render :core
      end

      def render_card view, card_args={}, format_args={}
        render_card_with_args view, card_args, format_args
      end

      alias_method :render_view, :render_card

      def render_card_with_args view, card_args={}, format_args={}, view_args={}
        card =
          if card_args.is_a?(Card)
            card_args
          elsif card_args.is_a?(Symbol) || card_args.is_a?(String) ||
                card_args.is_a?(Array)
            Card.fetch card_args
          elsif card_args[:name]
            fetch_with_attributes card_args.delete(:name), card_args
          else
            Card.new card_args.merge(name: "Tempo Rary")
          end
        card.format(format_args)._render(view, view_args)
      end

      def fetch_with_attributes name, card_args
        if Card.real? name
          card_args.each_with_object Card.fetch(name) do |(k, v), card|
            card.send "#{k}=", v
          end
        else
          Card.fetch name, new: card_args
        end
      end
    end
  end
end
