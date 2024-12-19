class Card
  class Bootstrap
    include Delegate
    extend ComponentLoader
    load_components

    attr_reader :context

    def initialize context=nil
      @context = context
    end

    def render(...)
      instance_exec(...)
    end
  end
end
