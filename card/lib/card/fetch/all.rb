class Card
  class Fetch
    # fetch-related Card instance methods
    module All
      # fetching from the context of a card
      def fetch traits, opts={}
        opts[:new][:supercard] = self if opts[:new]
        Array.wrap(traits).inject(self) do |card, trait|
          Card.fetch card.name.trait(trait), opts
        end
      end

      def newish opts
        reset_patterns
        Card.with_normalized_new_args opts do |norm_opts|
          handle_type norm_opts do
            assign_attributes norm_opts
            self.name = name # trigger superize_name
          end
        end
      end

      def refresh force=false
        return self unless force || frozen? || readonly?
        return unless id

        fresh_card = self.class.find id
        fresh_card.include_set_modules
        fresh_card
      end
    end
  end
end
