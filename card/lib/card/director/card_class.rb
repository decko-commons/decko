class Card
  class Director
    # director-related Card class methods
    module CardClass
      def create! opts
        card = new opts
        card.save!
        card
      end

      def create opts
        card = new opts
        card.save
        card
      end

      def ensure opts
        ensuring opts, &:save_if_needed
      end

      def ensure! opts
        ensuring opts, &:save_if_needed!
      end

      private

      def ensuring opts
        with_conflict_mode opts.delete(:conflict) do
          card = fetch_for_ensure opts
          ensuring_purity(card, opts) do |ensured_card, attempt|
            yield ensured_card if attempt
            ensured_card
          end
        end
      end

      def with_conflict_mode mode
        @conflict_mode = mode || :default
        yield
      ensure
        @conflict_mode = nil
      end

      def fetch_for_ensure opts
        main_mark = opts[:codename]&.to_sym || opts[:name]
        if id(main_mark)
          fetch(main_mark).tap { |card| card.assign_attributes opts }
        else
          new opts
        end
      end

      def ensuring_purity card, opts, &block
        if opts[:codename] && (other = other_card_with_name card, opts[:name].to_name)
          ensure_purity_advanced card, other, opts, &block
        else
          ensure_purity_simple card, &block
        end
      end

      def ensure_purity_advanced card, other, opts
        attempt_card = send "ensure_advanced_#{@conflict_mode}", card, other, opts
        attempt_card ? yield(attempt_card, true) : yield(card, false)
      end

      def ensure_purity_simple card
        attempt_save =
          case @conflict_mode
          when :override then true
          when :default  then card.pristine?
          when :defer    then card.new?
          else
            invalid_conflict_mode!
          end
        yield card, attempt_save
      end

      def ensure_advanced_defer card, other, _opts
        return unless card.new? # codenamed card doesn't exist yet

        card.name = other.name.alternative
        card
      end

      def ensure_advanced_default card, other, opts
        return unless card.pristine?

        if card.new? && other.pristine?
          other.assign_attributes opts
          other
        else
          ensure_non_conflicting_name card
        end
      end

      def ensure_advanced_override card, other, opts
        if card.new?
          other.assign_attributes opts
          other
        else
          other.name = other.name.alternative
          card.subcards.add other
          card
        end
      end

      def ensure_non_conflicting_name card
        card.name = card.new? ? card.name.alternative : card.name_before_act
        card
      end

      def other_card_with_name card, name
        card_with_name = name.card
        card_with_name if card_with_name&.id && (card_with_name.id != card.id)
      end

      def invalid_conflict_mode!
        raise Card::ServerError, "invalid conflict mode: #{@conflict_mode}. " \
                                 "Must be defer, default, or override"
      end
    end
  end
end
