class Card
  # Card::Env is a module for containing the variable details of the environment
  # in which Card operates.
  #
  # Env can differ for each request; Cardio.config should not.
  module Env
    extend LocationHistory
    extend RequestAssignments
    extend SlotOptions
    extend Serialization

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

      def with_params hash
        old_params = params.clone
        params.merge! hash
        yield
      ensure
        self.params = old_params
      end

      def hash hashish
        case hashish
        when Hash then hashish.clone
        when ActionController::Parameters then hashish.to_unsafe_h
        else {}
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
        self[:host]&.match?(/^localhost/)
      end

      def ajax?
        self[:ajax]
      end

      def html?
        !self[:controller] || self[:html]
      end

      private

      def method_missing method_id, *args
        case args.length
        when 0 then self[method_id]
        when 1 then self[method_id] = args[0]
        else super
        end
      end
    end
  end
end

Card::Env.reset
