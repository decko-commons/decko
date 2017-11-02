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

      def respond_to_missing? method, _include_private=false
        (method =~ RENDER_METHOD_RE) || template.respond_to?(method)
      end

      def method_missing method, *opts, &proc
        if method =~ RENDER_METHOD_RE
          api_render Regexp.last_match, opts
        else
          pass_method_to_template_object(method, opts, proc) { yield }
        end
      end

      def api_render match, opts
        # view can be part of method name or first argument
        view = match[:view] || opts.shift
        render! view, render_args(match[:underscore], match[:bang], opts)
      end

      def render_args underscore, bang, opts
        args = opts[0] ? opts.shift.clone : {}   # opts are opts ;)
        args[:optional] = (opts.shift || args[:optional] || :show) unless bang
        args[:skip_perms] = true if underscore
        args
      end

      def pass_method_to_template_object method, opts, proc
        proc = proc { |*a| raw yield(*a) } if proc
        response = root.template.send method, *opts, &proc
        response.is_a?(String) ? root.template.raw(response) : response
      end
    end
  end
end
