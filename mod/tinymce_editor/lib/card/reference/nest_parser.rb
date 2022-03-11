class Card
  class Reference
    # Extracts all information needed to generate the nest editor form
    # from a nest syntax string
    class NestParser
      NEST_OPTIONS = %i[view title show hide wrap help variant size params].freeze

      attr_reader :name, :view, :options, :item_options, :raw

      def self.new nest_string
        return super if nest_string.is_a? String

        OpenStruct.new(name: "", field?: true,
                       options: [], item_options: [],
                       raw: "{{+ }}")
      end

      def self.new_image name
        OpenStruct.new(name: name, field?: false,
                       view: "content",
                       options: [%i[size medium]],
                       item_options: [],
                       raw: "{{#{name}|view: content; size: medium}}")
      end

      def field?
        @field
      end

      def option_value name
        options.find  { |(key, _value)| key == name }&.second
      end

      def initialize nest_string
        @raw = nest_string
        # @default_item_view = default_item_view
        nest = Card::Content::Chunk::Nest.new nest_string, nil
        init_name nest.name
        extract_item_options nest.options
        @options = extract_options nest.options
      end

      private

      def init_name name
        @field = name.to_name.simple_relative?
        @name = @field ? name.to_s[1..-1] : name
      end

      def extract_options options, item_options=false
        applicable_options(options).each_with_object([]) do |key, res|
          if key.in? %i[show hide]
            res.concat viz_values(key, options)
          elsif key == :view && !item_options
            @view = options[key]
          else
            res << [key, options[key]]
          end
        end
      end

      def viz_values key, options
        Card::View.normalize_list(options[key]).map { |val| [key, val] }
      end

      def applicable_options options
        Card::Reference::NestParser::NEST_OPTIONS.select { |key| options[key] }
      end

      def extract_item_options options
        @item_options = []
        item_options = options[:items]
        while item_options
          next_item_options = item_options[:items]
          @item_options << extract_options(item_options, true)
          item_options = next_item_options
        end
        # @item_options << default_item_options
      end

      def default_item_options
        [:view, @default_item_view]
      end
    end
  end
end
