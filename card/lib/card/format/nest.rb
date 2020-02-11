class Card
  class Format
    # processing nests
    class Nest
      include Fetch

      attr_accessor :format, :card, :view, :view_opts, :format_opts
      def initialize format, cardish, view_opts={}, format_opts={}
        @format = format
        @view_opts = view_opts
        @format_opts = format_opts.clone
        @override = @format_opts.delete(:override) != false
        @card ||= fetch_card cardish
        # note: fetch_card can alter view and view_opts[:nest_name]
      end

      def prepare
        prepare_view_and_opts!
        subformat = prepare_subformat
        @view = subformat.modal_nest_view @view if @override
        yield subformat, view
      end

      private

      def prepare_view_and_opts!
        view_opts[:nest_name] ||= card.name
        @view ||= prepare_view
        # TODO: handle in closed / edit view definitions
        view_opts[:home_view] ||= %i[closed edit].member?(view) ? :open : view
      end

      def prepare_view
        view = view_opts[:view] || format.implicit_nest_view
        # TODO: canonicalize view and modal_nest_view handling should be in Card::View,
        # not here. (Make sure processing only happens on nests/root views)
        Card::View.normalize view
      end

      # @return [Format] subformat object
      def prepare_subformat
        return format if reuse_format?

        sub = format.subformat card, format_opts
        sub.main! if view_opts[:main]
        sub
      end

      # sometimes we use the same format (rather than a new subformat)
      # when nesting the same card. this reduces overhead and optimizes
      # caching
      def reuse_format?
        self_nest? && !nest_recursion_risk?
      end

      def self_nest?
        self_nest = view_opts[:nest_name] =~ /^_(self)?$/ &&
                    format.context_card == format.card

        # self nest in focal format should add depth (to catch recursions) but
        # remain focal
        format_opts[:focal] = true if self_nest && format.focal?
        self_nest
      end

      # don't reuse the format when there is a risk of recursion, because while nest
      # recursion is caught, view recursion is not.
      # TODO: catch view recursion and remove this. (Should be straightforward within voo)
      def nest_recursion_risk?
        content_view? || format.voo&.structure
      end

      def content_view?
        # TODO: this should be specified in view definition
        %i[
          bar expanded_bar core content titled open closed open_content one_line_content
        ].member? @view.to_sym
      end
    end
  end
end
