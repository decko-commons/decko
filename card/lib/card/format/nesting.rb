class Card
  class Format
    # the core of the nesting api
    module Nesting
      include Main
      include Subformat
      include Mode

      # @param cardish card mark
      # @param view_opts [Hash] {Card::View::Options view options}, passed on to render.
      # @param format_opts [Hash] opts will be passed on to subformat
      def nest cardish, view_opts={}, format_opts={}
        return "" if nest_invisible?

        nest = Card::Format::Nest.new self, cardish, view_opts, format_opts
        nest.prepare do |subformat, view|
          rendered = count_chars { subformat.render view, view_opts }
          block_given? ? yield(rendered, view) : rendered
        end
      end

      # Shortcut for nesting field cards
      # @example
      #   home = Card['home'].format
      #   home.nest :self         # => nest for '*self'
      #   home.field_nest :self   # => nest for 'Home+*self'
      def field_nest field, opts={}
        fullname = card.name.field(field) unless field.is_a? Card
        opts[:title] ||= Card.fetch_name(field).vary("capitalized")
        nest fullname, opts
      end

      # create a path for a nest with respect to the nest options
      def nest_path name, nest_opts={}
        path_opts = { slot: nest_opts.clone, mark: name }
        path_opts[:view] = path_opts[:slot].delete :view
        path path_opts
      end

      # view used if unspecified in nest.
      # frequently overridden in other formats
      def default_nest_view
        :name
      end

      def implicit_nest_view
        voo_items_view || default_nest_view
      end

      private

      def nest_invisible?
        nest_mode == :compact && @char_count && (@char_count > max_char_count)
      end

      def count_chars
        result = yield
        return result unless nest_mode == :compact && result

        @char_count ||= 0
        @char_count += result.length
        result
      end

      def max_depth
        Cardio.config.max_depth
      end

      def max_char_count
        Cardio.config.max_char_count
      end
    end
  end
end
