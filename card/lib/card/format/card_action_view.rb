class Card
  class Format
    # minimalist subclass of ActionView
    class CardActionView < ActionView::Base
      class << self
        def new controller
          super(lookup_context, { _routes: nil }, controller)
        end

        def lookup_context
          @lookup_context ||= ::ActionView::LookupContext.new CardController.view_paths
        end
      end

      def compiled_method_container
        self.class
      end
    end
  end
end
