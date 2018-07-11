# TODO: work in progress
class Card
  module Set
    # ActiveCard support: accessing plus cards as attributes
    module CodeNest
      def nest *args
        args.each do |arg|
          add_nest arg
        end
      end

      def add_nest args

      end
    end
  end
end
