class Card
  class Fetch
    # = Card#fetch
    #
    # A multipurpose retrieval operator that integrates caching, database lookups,
    # and "virtual" card construction
    module CardClass
      # Look for cards in
      # * cache
      # * database
      # * virtual cards
      #
      # @param args [Integer, String, Card::Name, Symbol, Array]
      #    one or more of the three unique identifiers
      #      1. a numeric id (Integer)
      #      2. a name/key (String or Card::Name)
      #      3. a codename (Symbol)
      #    If you pass more then one mark or an array of marks they get joined with a '+'.
      #    The final argument can be a hash to set the following options
      #      :skip_virtual               Real cards only
      #      :skip_modules               Don't load Set modules
      #      :look_in_trash              Return trashed card objects
      #      :local_only                 Use only local cache for lookup and storing
      #      new: { opts for Card#new }  Return a new card when not found
      # @return [Card]
      def fetch *args
        Card::Fetch.new(*args)&.retrieve_or_new
      rescue ActiveModel::RangeError => _e
        return Card.new name: "card id out of range: #{f.mark}"
      end

      # fetch only real (no virtual) cards
      #
      # @param mark - see #fetch
      # @return [Card]
      def [] *mark
        fetch(*mark, skip_virtual: true)
      end

      # fetch real cards without set modules loaded. Should only be used for
      # simple attributes
      #
      # @example
      #   quick_fetch "A", :self, :structure
      #
      # @param mark - see #fetch
      # @return [Card]
      def quick_fetch *mark
        fetch(*mark, skip_virtual: true, skip_modules: true)
      end

      # @return [Card]
      def fetch_from_cast cast
        fetch_args = cast[:id] ? [cast[:id].to_i] : [cast[:name], { new: cast }]
        fetch(*fetch_args)
      end

      #----------------------------------------------------------------------
      # ATTRIBUTE FETCHING
      # The following methods optimize fetching of specific attributes

      def id cardish
        case cardish
        when Integer then cardish
        when Card then cardish.id
        when Symbol then Card::Codename.id cardish
        else fetch_id cardish
        end
      end

      # @param mark_parts - see #fetch
      # @return [Integer]
      def fetch_id *mark_parts
        mark = Card::Fetch.new(*mark_parts)&.mark
        mark.is_a?(Integer) ? mark : quick_fetch(mark.to_s)&.id
      end

      # @param mark - see #fetch
      # @return [Card::Name]
      def fetch_name *mark, &block
        if (card = quick_fetch(*mark))
          card.name
        elsif block_given?
          yield.to_name
        end
      rescue => error
        rescue_fetch_name error, &block
      end

      # @param mark - see #fetch
      # @return [Integer]
      def fetch_type_id *mark
        fetch(*mark, skip_modules: true)&.type_id
      end

      # Enhanced fetch to support interpretation of URI parameters.
      # To normal fetching this adds:
      # - interpretation of the card hash (params[:card])
      # - handling conflicts between "mark" and "card" params
      #   removing
      # - special root-level parameters, including
      #   - type (String, added to card hash)
      #   - look_in_trash (boolean, applied to fetch)
      #   - assign (boolean, assignment of card attributes to existing cards
      def uri_fetch params
        card_opts = uri_fetch_opts params
        if params[:action] == "create"
          # FIXME: we currently need a "new" card to catch duplicates
          # (otherwise save will just act like a normal update)
          # We may need a "#create" instance method to handle this checking?
          Card.new card_opts
        else
          standard_uri_fetch params, card_opts
        end
      end

      private

      def standard_uri_fetch params, card_opts
        mark = params[:mark] || card_opts[:name]
        card = fetch mark, skip_modules: true,
                           standardize_name: true,
                           new: card_opts,
                           look_in_trash: params[:look_in_trash],
        card.assign_attributes card_opts if params[:assign] && card&.real?
        card&.include_set_modules
        card
      end

      def uri_fetch_opts params
        Env.hash(params[:card]).tap do |card_opts|
          card_opts[:type] ||= params[:type] if params[:type] # for /new/:type shortcut.
        end
      end

      def rescue_fetch_name error, &block
        if rescued_fetch_name_to_name? error, &block
          yield.to_name
        elsif error.is_a? ActiveModel::RangeError
          nil
        else
          raise error
        end
      end

      def rescued_fetch_name_to_name? error
        return unless block_given?

        error.is_a?(ActiveModel::RangeError) || error.is_a?(Error::CodenameNotFound)
      end
    end
  end
end
