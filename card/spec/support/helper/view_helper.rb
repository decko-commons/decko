class Card
  module SpecHelper
    module ViewHelper
      module ViewDescriber
        def describe_views *views, &block
          views.flatten.each do |v|
            let(:view) { v }
            describe "view: #{v}", &block
          end
        end
      end

      def expect_view view, format: :html
        expect(format_subject(format).render(view))
      end

      def view view_name, card: { name: "test card", type: :basic }, format: :html
        render_card_with_args view_name, card, format: format
      end

      def render_editor type
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
          elsif card_args.is_a?(Symbol) || card_args.is_a?(String)
            Card.fetch card_args
          elsif card_args[:name]
            Card.fetch card_args[:name], new: card_args
          else
            Card.new card_args.merge(name: "Tempo Rary")
          end
        card.format(format_args)._render(view, view_args)
      end
    end
  end
end
