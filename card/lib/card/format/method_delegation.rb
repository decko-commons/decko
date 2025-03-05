class Card
  class Format
    module MethodDelegation
      RENDER_METHOD_RE =
        /^
           (?<underscore>_)?  # leading underscore to skip permission check
           render
           (?:_(?<view>\w+))? # view name
           (?<bang>!)?        # trailing bang to skip optional check
        $/x

      def api_render match, opts
        # view can be part of method name or first argument
        view = match[:view] || opts.shift
        render! view, render_args(match[:underscore], match[:bang], opts)
      end

      def action_view
        @action_view ||= root? ? new_action_view : root.action_view
      end

      private

      def api_render? method
        method.match RENDER_METHOD_RE
      end

      def respond_to_missing? method, _include_private=false
        api_render?(method) || action_view?(method)
      end

      def action_view? method
        action_view.respond_to? method
      end

      # TODO: make it so we fall back to super if action_view can't handle method.
      # It's not as easy as `elsif api_render? method`, because respond_to gives
      # false for many methods action view can actually handle, like `h`
      def method_missing method, *opts, &proc, &block
        if (match = api_render? method)
          api_render match, opts
        else
          delegate_to_action_view method, opts, proc, &block
        end
      end

      def render_args underscore, bang, opts
        # opts is a list; args is a hash. we're using various inputs to build the hash
        interpret_render_opts opts do |args|
          args[:optional] = optional_render_opt opts, args unless bang
          args[:skip_perms] = true if underscore
        end
      end

      def interpret_render_opts opts, &block
        (opts[0] ? opts.shift.clone : {}).tap(&block)
      end

      def optional_render_opt opts, args
        opts.shift || args[:optional] || :show
      end

      def new_action_view
        CardActionView.new(controller).tap do |t|
          t.extend CardController._helpers
        end
      end

      def delegate_to_action_view method, opts, proc
        proc = proc { |*a| raw yield(*a) } if proc
        response = action_view.send method, *opts, &proc
        response.is_a?(String) ? action_view.raw(response) : response
      end
    end
  end
end
