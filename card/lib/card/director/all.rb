class Card
  class Director
    # director-related Card instance methods
    module All
      def act options={}, &block
        if act_card
          add_to_act options, &block
        else
          start_new_act(&block)
        end
      end

      def act_card
        Card::Director.act_card
      end

      def act_card?
        self == act_card
      end

      def save! *args
        as_subcard = args.first&.delete :as_subcard
        act(as_subcard: as_subcard) { super }
      end

      def save *args
        act { super }
      end

      def valid? *args
        act(validating: true) { super }
      end

      def update *args
        act { super }
      end

      def update! *args
        act { super }
      end

      alias_method :update_attributes, :update
      alias_method :update_attributes!, :update!

      private

      def start_new_act &block
        self.director = nil
        Director.run_act(self) do
          run_callbacks(:act, &block)
        end
      end

      def add_to_act options={}
        director.appoint self unless @director
        director.head = true unless options[:validating] || options[:as_subcard]
        yield
      end
    end
  end
end
