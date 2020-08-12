class Card
  # Translates keys to ids and vice versa via an intermediate "lex" representation
  # Note: the lexicon does NOT distinguish between trashed and untrashed cards.
  module Lexicon
    class << self
      # param id [Integer]
      # @return [String]
      def key id
        return unless id.present?

        (lex = id_to_lex id) && lex_to_key(lex)
      end

      # param name [String]
      # @return [Integer]
      def id name
        return unless name.present?

        (lex = name_to_lex name.to_name) && lex_to_id(lex)
      end

      def cache
        Card::Cache[Lexicon]
      end

      def add card
        lex = card.lex
        cache.write card.id.to_s, lex
        cache.write cache_key(lex), card.id
      end

      def update card
        add card
        cache.delete cache_key(card.old_lex)
      end

      # def delete card
      #   cache.delete card.id.to_s
      #   cache.delete cache_key(card.old_lex)
      # end

      def lex_to_key lex
        return lex unless lex&.is_a? Array
        lex.map do |side_id|
          key side_id or return
        end.join Card::Name.joint
      end

      def id_to_lex id
        cache.fetch id.to_s do
          result = Card.where(id: id).pluck(:key, :left_id, :right_id).first
          return unless result

          result[0] || [result[1], result[2]]
        end
      end

      private

      def name_to_lex name
        if name.simple?
          name.key
        elsif (left_id = id name.left_name) && (right_id = id name.right_name)
          [left_id, right_id]
        end
      end

      def lex_to_id lex
        cache.fetch cache_key(lex) do
          Card.where(lex_query(lex)).pluck(:id).first
        end
      end

      def lex_query lex
        lex.is_a?(Array) ? { left_id: lex[0], right_id: lex[1] } : { key: lex }
      end

      def cache_key lex
        "L-" + (lex.is_a?(Array) ? lex.join("-") : lex)
      end
    end
  end
end
