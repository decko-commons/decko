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

      def respond_to_missing? method, _include_private=false
        (method =~ RENDER_METHOD_RE) || action_view.respond_to?(method)
      end

      def method_missing method, *opts, &proc
        if method =~ RENDER_METHOD_RE
          api_render Regexp.last_match, opts
        else
          delegate_to_action_view(method, opts, proc) { yield }
        end
      end

      def render_args underscore, bang, opts
        args = opts[0] ? opts.shift.clone : {}   # opts are opts ;)
        args[:optional] = (opts.shift || args[:optional] || :show) unless bang
        args[:skip_perms] = true if underscore
        args
      end

      # TODO: review this. it's quite old, and there might be a better way to do this now.
      def new_action_view
        c = controller
        lookup_context = ActionView::LookupContext.new c.class.view_paths
        ActionView::Base.new(lookup_context, { _routes: c._routes }, c).tap do |t|
          t.extend c.class._helpers
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
