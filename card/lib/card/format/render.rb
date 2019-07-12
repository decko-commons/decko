class Card
  class Format
    # View rendering methods.
    #
    module Render
      # view=open&layout=simple
      def render! view, view_options={}
        voo = View.new self, view, view_options, @voo
        with_voo voo do
          voo.process do |final_view|
            final_render final_view
          end
        end
      rescue StandardError => e
        rescue_view e, view
      end

      def with_voo voo
        old_voo = @voo
        @voo = voo
        yield
      ensure
        @voo = old_voo
      end

      def with_wrapper
        if voo.layout.present?
          voo.wrap ||= []
          layout = voo.layout.to_name.key
          # don't wrap twice with modals or overlays
          # this can happen if the view is wrapped with modal
          # and is requested with layout=modal param
          voo.wrap.unshift layout unless voo.wrap.include? layout.to_sym
        end

        @rendered = yield
        wrap_with_wrapper
      end

      def wrap_with_wrapper
        return @rendered unless voo.wrap.present?

        voo.wrap.reverse.each do |wrapper, opts|
          @rendered = render_with_wrapper(wrapper, opts) ||
                      render_with_card_layout(wrapper) ||
                      raise_wrap_error(wrapper)
        end
        @rendered
      end

      def render_with_wrapper wrapper, opts
        try("wrap_with_#{wrapper}", opts) { @rendered }
      end

      def render_with_card_layout mark
        return unless Card::Layout.card_layout? mark

        Card::Layout::CardLayout.new(mark, self).render
      end

      def raise_wrap_error wrapper
        if wrapper.is_a? String
          raise Card::Error::UserError, "unknown layout card: #{wrapper}"
        else
          raise ArgumentError, "unknown wrapper: #{wrapper}"
        end
      end

      def before_view view
        try "_before_#{view}"
      end

      def voo
        @voo ||= View.new self, nil, {}
      end

      def show_view? view, default_viz=:show
        voo.process_visibility # trigger viz processing
        visibility = voo.viz_hash[view] || default_viz
        visibility == :show
      end

      def final_render view
        current_view(view) do
          with_wrapper do
            method = view_method view
            rendered = final_render_call method
            add_debug_info view, method, rendered
          end
        end
      end

      def final_render_call method
        method.call
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
        source_location.first.gsub(%r{^.+mod\d+-([^/]+)}, '\1: ') + ":" +
          source_location.second.to_s
      end

      # :standard, :always, :never
      def view_cache_setting view
        voo&.cache || view_setting(:cache, view) || :standard
      end

      def view_setting setting_name, view
        try Card::Set::Format.view_setting_method_name(view, setting_name)
      end

      def stub_render cached_content
        stub_debugging do
          expand_stubs cached_content
        end
      end

      def stub_debugging
        result = yield
        if Rails.env.development? && result =~ /stub/
          Rails.logger.debug "STUB IN RENDERED VIEW: #{card.name}: " \
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
        conto.process_chunks

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
          raise Card::Error::UserError, unsupported_view_error_message(view)
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

      def stub_nest stub_hash
        prepare_stub_nest(stub_hash) do |stub_card, view_opts|
          nest stub_card, view_opts, stub_hash[:format_opts]
        end
      end
    end
  end
end
