class Card
  # shared methods for bootstrapping in card formats and act renderers
  module Bootstrapper
    extend Bootstrap::ComponentLoader

    def bootstrap
      @bootstrap ||= Bootstrap.new(self)
    end

    def bs(...)
      bootstrap.render(...)
    end

    components.each do |component|
      delegate component, to: :bootstrap, prefix: :bs
    end
  end
end
