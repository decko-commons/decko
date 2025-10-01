class Card
  class Bootstrap
    # delegating methods to context
    module Delegate
      def method_missing(method_name, *, &)
        # return super unless @context.respond_to? method_name
        if block_given?
          @context.send(method_name, *, &)
        else
          @context.send(method_name, *)
        end
      end

      def respond_to_missing? method_name, _include_private=false
        @context.respond_to? method_name
      end
    end
  end
end
