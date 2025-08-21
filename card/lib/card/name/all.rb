class Card
  class Name
    # methods connecting Card to Card::Name
    module All
      include Parts
      include Descendants

      # TODO: use delegations and include more name functions
      delegate :simple?, :compound?, :junction?, to: :name
      attr_reader :supercard

      def name
        @name ||= left_id ? Lexicon.lex_to_name([left_id, right_id]) : super.to_name
      end
      alias_method :cardname, :name

      def key
        @key ||= left_id ? name.key : super
      end

      def name= newname
        @name = superize_name newname.to_name
        self.key = @name.key
        update_subcard_names @name
        write_attribute :name, (@name.simple? ? @name.s : nil)
        assign_side_ids
        @name
      end

      def [] *args
        case args[0]
        when Integer, Range
          fetch_name = Array.wrap(name.parts[args[0]]).compact.join Name.joint
          Card.fetch(fetch_name, args[1] || {}) unless simple?
        else
          super
        end
      end

      def autoname name
        if Card.exist?(name) || Director.include?(name)
          autoname name.next
        else
          name
        end
      end

      def update_superleft newname=nil
        newname ||= name
        @superleft = @supercard if newname.field_of? @supercard.name
      end

      def update_subcard_names new_name, name_to_replace=nil
        return unless @subcards

        subcards.each do |subcard|
          update_subcard_name subcard, new_name, name_to_replace if subcard.new?
        end
      end

      def id_string
        "~#{id}"
      end

      def key= newkey
        return if newkey == key

        update_cache_key key do
          write_attribute :key, (name.simple? ? newkey : nil)
          @key = newkey
        end
        clean_patterns
        @key
      end

      private

      def assign_side_ids
        if name.simple?
          self.left_id = self.right_id = nil
        else
          assign_side_id :left_id=, :left_name
          assign_side_id :right_id=, :right_name
        end
      end

      # assigns left_id and right_id based on names.
      # if side card is new, id is temporarily stored as -1
      def assign_side_id side_id_equals, side_name
        side_id = Lexicon.id(name.send(side_name)) || -1
        send side_id_equals, side_id
      end

      def superize_name cardname
        return cardname unless @supercard

        @supercard.subcards.rename key, cardname.key
        update_superleft cardname
        @supercard.name.relative? ? cardname : cardname.absolute_name(@supercard.name)
      end

      def clean_patterns
        return unless patterns?

        reset_patterns
        patterns
      end

      def update_cache_key oldkey
        yield
        was_in_cache = Card.cache.temp.delete oldkey
        Card.write_to_temp_cache self if was_in_cache
      end

      def update_subcard_name subcard, new_name, name_to_replace
        name_to_replace ||= name_to_replace_for_subcard subcard, new_name
        subcard.name = subcard.name.swap name_to_replace, new_name.s
        # following needed?  shouldn't #name= trigger this?
        subcard.update_subcard_names new_name, name
      end

      def name_to_replace_for_subcard subcard, new_name
        # if subcard has a relative name like +C
        # and self is a subcard as well that changed from +B to A+B then
        # +C should change to A+B+C. #replace doesn't work in this case
        # because the old name +B is not a part of +C
        if subcard.name.starts_with_joint? && new_name.parts.first.present?
          "".to_name
        else
          name
        end
      end
    end
  end
end
