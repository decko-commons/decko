# require_dependency "card/env/location"
# require_dependency "card/env/location_history"

class Card
  # Card::Env is a module for containing the variable details of the environment
  # in which Card operates.
  #
  # Env can differ for each request; Card.config should not.
  module Env
    extend LocationHistory

    SERIALIZABLE_ATTRIBUTES = ::Set.new %i[
      main_name params ip ajax html host protocol salt
    ]

    class << self
      def reset args={}
        @env = { main_name: nil }
        return self unless (c = args[:controller])

        self[:controller] = c
        self[:session]    = c.request.session
        self[:params]     = c.params
        self[:ip]         = c.request.remote_ip
        self[:ajax]       = assign_ajax(c)
        self[:html]       = assign_html(c)
        self[:host]       = assign_host(c)
        self[:protocol]   = assign_protocol(c)
        self
      end

      def [] key
        @env[key.to_sym]
      end

      def []= key, value
        @env[key.to_sym] = value
      end

      def params
        self[:params] ||= {}
      end

      def slot_opts
        # FIXME:  upgrade to safe parameters
        self[:slot_opts] ||= begin
          opts = params[:slot]&.clone || {}
          opts = opts.to_unsafe_h if opts.is_a? ActionController::Parameters
          opts.merge! shortcut_slot_opts
          opts.deep_symbolize_keys.slice(*Card::View::Options.slot_keys)
        end
      end

      def session
        self[:session] ||= {}
      end

      def reset_session
        if session.is_a? Hash
          self[:session] = {}
        else
          self[:controller]&.reset_session
        end
      end

      def success cardname=nil
        self[:success] ||= Env::Success.new(cardname, params[:success])
      end

      def localhost?
        self[:host] && self[:host] =~ /^localhost/
      end

      def ajax?
        self[:ajax]
      end

      def html?
        !self[:controller] || self[:html]
      end

      def serialize
        @env.select { |k, _v| SERIALIZABLE_ATTRIBUTES.include?(k) }
      end

      # @param serialized_env [Hash]
      def with serialized_env
        tmp_env = serialize if @env
        @env ||= {}
        @env.update serialized_env
        yield
      ensure
        @env.update tmp_env if tmp_env
      end

      private

      def assign_ajax c
        c.request.xhr? || c.request.params[:simulate_xhr]
      end

      def assign_html c
        [nil, "html"].member?(c.params[:format])
      end

      def assign_host c
        Card.config.override_host || c.request.env["HTTP_HOST"]
      end

      def assign_protocol c
        Card.config.override_protocol || c.request.protocol
      end

      def method_missing method_id, *args
        case args.length
        when 0 then self[method_id]
        when 1 then self[method_id] = args[0]
        else super
        end
      end

      def shortcut_slot_opts
        opts = {}
        opts[:size] = params[:size].to_sym if params[:size]
        opts[:items] = { view: params[:item].to_sym } if slot_items_shortcut?
        opts
      end

      def slot_items_shortcut?
        params[:item].present? && !params.dig(:slot, :items, :view).present?
      end
    end
  end
end

Card::Env.reset
