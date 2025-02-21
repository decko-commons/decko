class Card
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
