class Card
  module Set
    # accessing plus cards as attributes
    module Trait
      def card_accessor *args
        options = args.extract_options!
        add_traits args, options.merge(reader: true, writer: true)
      end

      def card_reader *args
        options = args.extract_options!
        add_traits args, options.merge(reader: true)
      end

      def card_writer *args
        options = args.extract_options!
        add_traits args, options.merge(writer: true)
      end

      def require_field *fields
        options = fields.last.is_a?(Hash) ? fields.pop : {}
        fields.each do |field|
          Card::Set::RequiredField.new(self, field, options).add
        end
      end

      private

      def add_attributes *args
        Card.set_specific_attributes ||= []
        Card.set_specific_attributes += args.map(&:to_sym)
        Card.set_specific_attributes.uniq!
      end

      def get_traits mod
        Card::Set.traits ||= {}
        Card::Set.traits[mod] || Card::Set.traits[mod] = {}
      end

      def add_traits traits, options
        mod_traits = get_traits self
        new_opts = new_trait_opts options

        traits.each do |trait|
          define_trait_card trait, new_opts
          define_trait_reader trait if options[:reader]
          define_trait_writer trait if options[:writer]
          assign_trait_type trait, options[:type]

          mod_traits[trait.to_sym] = options
        end
      end

      def assign_trait_type trait, type
        return unless type && (parts = trait_module_key_parts trait)
        assign_type type, normalize_const(parts)
      end

      def trait_module_key_parts trait
        if all_set?
          [:right, trait]
        elsif type_set?
          [:type_plus_right, set_name_parts[3], trait]
        end
      end

      def new_trait_opts options
        %i[type default_content].each_with_object({}).each do |key, hash|
          hash[key] = options[key] if options[key]
        end
      end

      def define_trait_card trait, opts
        define_method "#{trait}_card" do |sub = false|
          if sub && (card = subfield trait)
            return card
          end
          # opts = opts.clone.merge supercard: card
          fetch trait.to_sym, new: opts.clone, eager_cache: true
        end
      end

      def define_trait_reader trait
        define_method trait do
          send("#{trait}_card").content
        end
      end

      def define_trait_writer trait
        define_method "#{trait}=" do |value|
          card = send "#{trait}_card"
          subcards.add name: card.name, type_id: card.type_id, content: value
          instance_variable_set "@#{trait}", value
        end
      end
    end
  end
end
