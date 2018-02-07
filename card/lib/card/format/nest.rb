class Card
  class Format
    module Nest
      include Fetch
      include Main
      include Subformat
      include Mode

      # @param cardish card mark
      # @param options [Hash]
      # @option options [Symbol] view
      # @option options [Symbol, Array<Symbol>] :hide hide optional subviews
      # @option options [Symbol, Array<Symbol>] :show show optional subviews
      # @option options [String] :title
      # @param override ??
      def nest cardish, options={}, override=true, &block
        return "" if nest_invisible?
        nested_card = fetch_nested_card cardish, options
        view, options = interpret_nest_options nested_card, options

        with_nest_mode options.delete(:mode) do
          nest_render nested_card, view, options, override, &block
        end
      end

      # nested by another card's content
      # (as opposed to a direct API nest)
      def content_nest opts={}
        return opts[:comment] if opts.key? :comment # commented nest
        nest_name = opts[:nest_name]
        return main_nest(opts) if main_nest?(nest_name)
        nest nest_name, opts
      end

      # create a path for a nest with respect ot the nest options
      def nest_path name, nest_opts={}
        path_opts = { slot: nest_opts.clone }
        path_opts[:view] = path_opts[:slot].delete :view
        page_path name, path_opts
      end

      def interpret_nest_options nested_card, options
        options[:nest_name] ||= nested_card.name
        view = options[:view] || implicit_nest_view
        view = Card::View.canonicalize view

        # FIXME: should handle in closed / edit view definitions
        options[:home_view] ||= [:closed, :edit].member?(view) ? :open : view

        [view, options]
      end

      def implicit_nest_view
        view = voo_items_view || default_nest_view
        Card::View.canonicalize view
      end

      def default_nest_view
        :name
      end

      def nest_render nested_card, view, options, override
        subformat = nest_subformat nested_card, options, view
        view = subformat.modal_nest_view view if override
        rendered = count_chars { subformat.render view, options }
        block_given? ? yield(rendered, view) : rendered
      end

      def nest_subformat nested_card, opts, view
        return self if reuse_format? opts[:nest_name], view
        sub = subformat nested_card
        sub.main! if opts[:main]
        sub
      end

      def reuse_format? nest_name, view
        nest_name =~ /^_(self)?$/ &&
          card.context_card == card &&
          !nest_recursion_risk?(view)
      end

      def nest_recursion_risk? view
        content_view?(view) && voo.structure
      end

      def content_view? view
        # TODO: this should be specified in view definition
        [
          :core, :content, :titled, :open, :closed, :open_content
        ].member? view.to_sym
      end

      # Main difference compared to #nest is that you can use
      # codename symbols to get nested fields
      # @example
      #   home = Card['home'].format
      #   home.nest :self         # => nest for '*self'
      #   home.field_nest :self   # => nest for 'Home+*self'
      def field_nest field, opts={}
        field = card.name.field(field) unless field.is_a? Card
        nest field, opts
      end

      # opts[:home_view] = [:closed, :edit].member?(view) ? :open : view
      # FIXME: special views should be represented in view definitions

      private

      def nest_invisible?
        nest_mode == :closed && @char_count && (@char_count > max_char_count)
      end

      def count_chars
        result = yield
        return result unless nest_mode == :closed && result
        @char_count ||= 0
        @char_count += result.length
        result
      end

      def max_depth
        Card.config.max_depth
      end

      def max_char_count
        Card.config.max_char_count
      end
    end
  end
end
