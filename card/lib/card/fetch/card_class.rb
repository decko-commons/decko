class Card
  class Fetch
    # A multipurpose retrieval system that integrates caching, database lookups,
    # and "virtual" card construction
    module CardClass
      # Look for cards in
      #   * cache
      #   * database
      #   * virtual cards
      #
      # @param args [Integer, String, Card::Name, Symbol, Array]
      #    Initials args must be one or more "marks," which uniquely idenfify cards:
      #
      #
      #      1. a name/key. (String or Card::Name)
      #      2. a numeric id. Can be (a) an Integer or (b) a String with an integer
      #         prefixed with a tilde, eg "~1234"
      #      3. a codename. Can be (a) a Symbol or (b) a String with a colon prefix,
      #         eg :mycodename
      #
      #    If you pass more then one mark or an array of marks they get joined with a '+'.
      #    The final argument can be a Hash to set the following options
      #
      #        :skip_virtual               Real cards only
      #        :skip_modules               Don't load Set modules
      #        :look_in_trash              Return trashed card objects
      #        :local_only                 Use only local cache for lookup and storing
      #        new: { opts for Card#new }  Return a new card when not found
      #
      # @return [Card]
      def fetch(*)
        f = Fetch.new(*)
        f.retrieve_or_new
      rescue ActiveModel::RangeError => _e
        Card.new name: "card id out of range: #{f.mark}"
      end

      # a shortcut for fetch that returns only real cards (no virtuals)
      #
      # @param mark [various] - see {#fetch}
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

      # numerical card id
      # @params cardish [various] interprets integers as id, symbols as codename, etc
      # @return [Integer]
      def id cardish
        case cardish
        when Integer then cardish
        when Card    then cardish.id
        when Symbol  then Codename.id cardish
        when String  then Lexicon.id cardish
        else quick_fetch(cardish)&.id
        end
      end

      # DEPRECATED
      # - use mark.cardname
      #
      # @param mark - see #fetch
      # @return [Card::Name]
      def fetch_name *mark
        quick_fetch(*mark)&.name
      end

      # @param mark - see #fetch
      # @return [Integer]
      def fetch_type_id *mark
        fetch(*mark, skip_modules: true)&.type_id
      end

      # Specialized fetching appropriate for cards requested by URI
      # @param params [Hash] hash in the style of parameters expected by Decko
      # @option params [Hash] :card arguments for Card.new
      # @option params [String] :mark.
      # @option params [String] :type shortcut for card[:type]
      # @option params [True/False] :look_in_trash - passed to Card.fetch
      # @option params [True/False] :assign - override attributes of fetched card with
      #   card hash
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
        card = fetch mark, new: card_opts,
                           skip_modules: true,
                           look_in_trash: params[:look_in_trash]
        card.assign_attributes card_opts if params[:assign] && card&.real?
        card&.include_set_modules
        card
      end

      def uri_fetch_opts params
        Env.hash(params[:card]).tap do |opts|
          opts[:type] ||= params[:type] if params[:type] # for /new/:type shortcut.
          opts[:name] ||= Name[params[:mark]]&.tr "_", " "
        end
      end
    end
  end
end
