class Card
  class Fetch
    # = Card#fetch
    #
    # A multipurpose retrieval operator that integrates caching, database lookups,
    # and "virtual" card construction
    module AllClass
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

      # fetch real cards without set modules loaded. Should only be used for simple attributes
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

      # a fetch method to support the needs of the card controller.
      # should be in Decko?
      def controller_fetch args
        card_opts = controller_fetch_opts args
        if args[:action] == "create"
          # FIXME: we currently need a "new" card to catch duplicates
          # (otherwise save will just act like a normal update)
          # We may need a "#create" instance method to handle this checking?
          Card.new card_opts
        else
          standard_controller_fetch args, card_opts
        end
      end

      private

      def standard_controller_fetch args, card_opts
        mark = args[:mark] || card_opts[:name]
        card = Card.fetch mark, skip_modules: true,
                                look_in_trash: args[:look_in_trash],
                                new: card_opts
        card.assign_attributes card_opts if args[:assign] && card&.real?
        card&.include_set_modules
        card
      end

      def controller_fetch_opts args
        opts = Env.hash args[:card]
        opts[:type] ||= args[:type] if args[:type]
        # for /new/:type shortcut.  we should handle in routing and deprecate this
        opts[:name] ||= Name.url_key_to_standard args[:mark]
        opts
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
