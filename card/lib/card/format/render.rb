class Card
  class Format
    # View rendering methods.
    #
    module Render
      MAX_LAYOUT_NESTING = 15

      def render! view, view_options={}
        voo = View.new self, view, view_options, @voo
        with_voo voo do
          voo.process do |final_view|
            with_layouts(final_view) do
              final_render final_view
            end
          end
        end
      rescue => e
        rescue_view e, view
      end

      def with_layouts _view, &block
        return yield unless layouts?
        @layout_stack = [block] + voo.layouts.reverse
        @layout_depth_count = 0
        render_layouts
      end

      def render_layouts
        while layouts?
          check_layout_deepness
          @layout_depth_count += 1
          process_next_layout
        end
      end

      def process_next_layout
        layout = @layout_stack.pop
        if layout.respond_to?(:call)
          layout.call
        else
          send Card::Set::Format.layout_method_name(layout)
        end
      end

      def check_layout_deepness
        if @layout_depth_count > MAX_LAYOUT_NESTING
          raise Card::Error, "layouts nested too deep"
        end
      end

      def wrap_with_layout layout, &block
        voo.layout.unshift layout
        @inner_render.push block
        render_layouts
      end

      def layout_nest
        render_layouts
      end

      def layouts?
        @layout_stack.present?
      end

      def with_voo voo
        old_voo = @voo
        @voo = voo
        yield
      ensure
        @voo = old_voo
      end

      def before_view view
        try "_before_#{view}"
      end

      def voo
        @voo
      end

      def show_view? view, default_viz=:show
        voo.process_visibility_options # trigger viz processing
        visibility = voo.viz_hash[view] || default_viz
        visibility == :show
      end

      def final_render view
        current_view(view) do
          method = view_method view
          rendered = method.call
          add_debug_info view, method, rendered
        end
      end

      def add_debug_info view, method, rendered
        return rendered unless show_debug_info?
        <<-HTML
          <view-debug view='#{safe_name}##{view}' src='#{pretty_path method.source_location}' module='#{method.owner}'/>
          #{rendered}
        HTML
      end

      def show_debug_info?
        Env.params[:debug] == "view"
      end

      def pretty_path source_location
        source_location.first.gsub(%r{^.+mod\d+-([^/]+)}, '\1: ') + ':' +
          source_location.second.to_s
      end

      # setting (:alway, :never, :nested) designated in view definition
      def view_cache_setting view
        coded_setting = view_setting(:cache, view) || :standard
        # method = self.class.view_cache_setting_method view
        # coded_setting = respond_to?(method) ? send(method) : :standard
        return :never if coded_setting == :never
        # seems unwise to override a hard-coded "never"
        (voo && voo.cache) || coded_setting
      end

      def view_setting setting_name, view
        method = self.class.view_setting_method_name view, setting_name
        try method
      end

      def stub_render cached_content
        result = expand_stubs cached_content do |stub_hash|
          prepare_stub_nest(stub_hash) do |stub_card, view_opts|
            nest stub_card, view_opts, stub_hash[:format_opts]
          end
        end
        if result =~ /stub/
          Rails.logger.info "STUB IN RENDERED VIEW: #{card.name}: " \
                            "#{voo.ok_view}\n#{result}"
        end
        result
      end

      def prepare_stub_nest stub_hash
        stub_card = Card.fetch_from_cast stub_hash[:cast]
        view_opts = stub_hash[:view_opts]
        voo.normalize_special_options! view_opts
        if stub_card&.key.present? && stub_card.key == card.key
          view_opts[:nest_name] ||= "_self"
        end
        yield stub_card, view_opts
      end

      def expand_stubs cached_content
        return cached_content unless cached_content.is_a? String

        conto = Card::Content.new cached_content, self, chunk_list: :stub
        conto.process_each_chunk do |stub_hash|
          yield(stub_hash)
        end

        if conto.pieces.size == 1
          # for stubs in json format this converts a single stub back
          # to it's original type (e.g. a hash)
          conto.pieces.first.to_s
        else
          conto.to_s
        end
      end

      def view_method view
        unless supports_view? view
          voo.unsupported_view = view
          view = :unsupported_view
        end
        method Card::Set::Format.view_method_name(view)
      end

      def supports_view? view
        respond_to? Card::Set::Format.view_method_name(view)
      end

      def current_view view
        old_view = @current_view
        @current_view = view
        yield
      ensure
        @current_view = old_view
      end
    end
  end
end
