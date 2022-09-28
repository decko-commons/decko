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
        with_conflict_mode opts.delete(:conflict) do
          card = fetch_for_ensure opts
          ensuring_purity card, opts do |ready_card|
            ready_card.save_if_needed!
          end
        end
      end

      private

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
        if codename && (other = other_card_with_name card, opts[:name].to_name)
          send "ensure_with_codename_#{conflict_mode}",
               card, other, opts, &block
        else
          ensure_purity_simple card, &block
        end
      end

      def ensure_purity_simple card
        case @conflict_mode
        when :override then yield card
        when :default  then yield card if card.pristine?
        when :defer    then yield card if card.new?
        else
          invalid_conflict_mode!
        end
      end

      def ensure_with_codename_defer card, other, _opts
        return unless card.new? # codenamed card doesn't exist yet

        card.name = other.name.alternative
        yield card
      end

      def ensure_with_codename_default card, other, opts
        if card.new? && other.pristine?
          other.assign_attributes opts
          yield other
        elsif card.pristine?
          card.name = card.new? ? other.name.alternative : card.name_before_act
          yield card
        end
      end

      def ensure_with_codename_override card, other, opts
        if card.new?
          other.assign_attributes opts
          yield other
        else
          other.name = other.name.alternative
          card.subcards.add other
          yield card
        end
      end

      def other_card_with_name card, name
        card_with_name = name.card
        card_with_name if card_with_name&.id & (card_with_name.id != card.id)
      end

      def invalid_conflict_mode!
        raise Card::ServerError, "invalid conflict mode: #{@conflict_mode}. " \
                                 "Must be defer, default, or override"
      end
    end
  end
end
