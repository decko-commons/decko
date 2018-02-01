class Card
  class Format
    # View rendering methods.
    #
    module Render
      def render! view, args={}
        voo = View.new self, view, args, @voo
        with_voo voo do
          voo.process do |final_view, options|
            final_render final_view, options
          end
        end
      rescue => e
        rescue_view e, view
      end

      def with_voo voo
        old_voo = @voo
        @voo = voo
        yield
      ensure
        @voo = old_voo
      end

      def view_options_with_defaults view, options
        default_method = "default_#{view}_args"
        send default_method, options if respond_to? default_method
        options
      end

      def voo
        @voo
      end

      def show_view? view, default_viz=:show
        voo.process_visibility_options # trigger viz processing
        visibility = voo.viz_hash[view] || default_viz
        visibility == :show
      end

      def final_render view, args
        current_view(view) do
          method = view_method view
          rendered = method.arity.zero? ? method.call : method.call(args)
          add_debug_info view, method, rendered
        end
      end

      def add_debug_info view, method, rendered
        return rendered unless show_debug_info?
        <<-HTML
          <view-debug view='#{card.name}##{view}' src='#{pretty_path method.source_location}' module='#{method.owner}'/>
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
        method = self.class.view_cache_setting_method view
        coded_setting = respond_to?(method) ? send(method) : :standard
        return :never if coded_setting == :never
        # seems unwise to override a hard-coded "never"
        (voo && voo.cache) || coded_setting
      end

      def stub_render cached_content
        result = expand_stubs cached_content do |stub_hash|
          prepare_stub_nest(stub_hash) do |stub_card, mode, options, override|
            with_nest_mode(mode) { nest stub_card, options, override }
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
        stub_options = stub_hash[:options]
        if stub_card&.key.present? && stub_card.key == card.key
          stub_options[:nest_name] ||= "_self"
        end
        yield stub_card, stub_hash[:mode], stub_options, stub_hash[:override]
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
        method view_method_name(view)
      end

      def supports_view? view
        respond_to? view_method_name(view)
      end

      def view_method_name view
        "_view_#{view}"
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
