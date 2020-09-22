class Card
  class Subcards
    # Methods for adding subcards
    module Add
      # @example Add a subcard with name 'spoiler'
      #   add 'spoiler', type: 'Phrase', content: 'John Snow is a Targaryen'
      #   card_obj = Card.new name: 'spoiler', type: 'Phrase',
      #                       content: 'John Snow is a Targaryen'
      #   add card_obj
      #   add name: 'spoiler', type: 'Phrase', content: 'John Snow is a Targaryen'
      #
      # @example Add a subcard that is added in the integration phase
      #     (and hence doesn't hold up the transaction for the main card)
      #   add 'spoiler', content: 'John Snow is a Targaryen'
      #   add card_obj, delayed: true

      def << value
        add value
      end

      def []= name, card_or_attr
        case card_or_attr
        when Hash
          new_by_attributes name, card_or_attr
        when Card
          new_by_card card_or_attr
        end
      end

      def add *args
        case args.first
        when Card then new_by_card args.first
        when Hash then add_hash args.first
        else new_by_attributes(*args)
        end
      end

      def add_hash hash
        if (name = hash.delete :name)
          new_by_attributes name, hash
        else
          multi_add hash
        end
      end

      def add_child name, args
        name = name.is_a?(Symbol) ? name.cardname : name.to_name
        add name.prepend_joint, args
      end
      alias_method :add_field, :add_child

      def new_by_card card
        card.supercard = @context_card
        if !card.name.simple? && card.name.field_of?(@context_card.name)
          card.superleft = @context_card
        end
        @keys << card.key
        Card.write_to_soft_cache card
        card.director = @context_card.director.subdirectors.add card
        card
      end

      def new_by_attributes name, attributes={}
        attributes ||= {}
        absolute_name = absolutize_subcard_name name
        subcard_args = extract_subcard_args! attributes
        card = initialize_by_attributes absolute_name, attributes
        subcard = new_by_card card
        card.subcards.add subcard_args
        subcard
      end

      def initialize_by_attributes name, attributes
        Card.assign_or_newish name, attributes, local_only: true
      end

      # TODO: this method already exists as card instance method in
      #   tracked_attributes.rb. Find a place for it where its accessible
      #   for both. There is one important difference. The keys are symbols
      # here instead of strings
      def extract_subcard_args! args
        subcards = args.delete(:subcards) || {}
        if (subfields = args.delete(:subfields))
          subfields.each_pair do |key, value|
            subcards[normalize_subfield_key(key)] = value
          end
        end
        args.keys.each do |key|
          subcards[key] = args.delete(key) if key =~ /^\+/
        end
        subcards
      end

      private

      # ensure a leading '+'
      def normalize_subfield_key key
        key = Card::Codename.name(key) if key.is_a?(Symbol) && Card::Codename.exist?(key)
        key.to_name.prepend_joint
      end

      # Handles hash with several subcards
      def multi_add args
        args.each_pair do |key, val|
          case val
          when String, Array, Integer
            new_by_attributes key, content: val
          when Card
            val.name = absolutize_subcard_name key
            new_by_card val
          when nil
            next
          else
            new_by_attributes key, val
          end
        end
      end
    end
  end
end
