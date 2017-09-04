class Bootstrap
  class Component
    class Panel < OldComponent
      def_div_method :panel, "card"
      def_div_method :heading, "card-header"
      def_div_method :body, "card-block"
    end
  end
end
