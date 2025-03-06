class Card
  class Bootstrap
    class Component
      # support class for bootstrap panels
      class Panel < OldComponent
        def_div_method :panel, "card"
        def_div_method :heading, "card-header"
        def_div_method :body, "card-body"
      end
    end
  end
end
