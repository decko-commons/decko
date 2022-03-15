class Card
  class Name
    # Name-related Card class methods
    module CardClass
      def rename! oldname, newname
        Card[oldname].update! name: newname
      end

      def uniquify_name name, rename=:new
        name = name.to_name
        return name unless Card.exists? name

        uniq_name = generate_alternative_name name
        return uniq_name unless rename == :old

        rename!(name, uniq_name)
        name
      end

      private

      def generate_alternative_name name
        uniq_name = "#{name} 1"
        uniq_name.next! while Card.exists?(uniq_name)
        uniq_name
      end
    end
  end
end
