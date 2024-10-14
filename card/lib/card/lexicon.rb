class Card
  # Translates names to ids and vice versa via a cached "lex" representation:
  # name for simple cards, [left_id, right_id] for compound cards.
  #
  # Note, unlike Card::Fetch, Card::Lexicon: does NOT return local name changes
  # until stored
  module Lexicon
    class << self
      # param id [Integer]
      # @return [String]
      def name id
        return unless id.present?

        name = (lex = id_to_lex id) && lex_to_name(lex)
        (name || "").to_name
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

      def update card
        add card
        expire_lex card.lex_before_act
      end

      def delete card
        cache.delete card.id.to_s
        cache.delete cache_key(card.lex_before_act)
      end

      def lex_to_name lex
        return lex unless lex.is_a? Array

        lex.map { |side_id| name side_id or return }.join(Card::Name.joint).to_name
      end

      def cache_key lex
        "L-#{lex.is_a?(Array) ? lex.join('-') : lex.to_name.key}"
      end

      def lex_query lex
        if lex.is_a?(Array)
          { left_id: lex.first, right_id: lex.last }
        else
          { key: lex.to_name.key }
        end
      end

      # this is to address problems whereby renaming errors leave the lexicon broken.
      # NEEDS TESTING
      def rescuing
        @act_lexes = []
        @act_ids = []
        yield
      rescue StandardError => e
        @act_lexes.each { |lex| expire_lex lex }
        @act_ids.each { |id| expire_id id }
        @act_lexes = @act_ids = nil
        raise e
      end

      private

      def add card
        lex = card.lex
        @act_lexes << lex
        @act_ids << card.id
        cache.write card.id.to_s, lex
        cache.write cache_key(lex), card.id
      end

      def expire_lex lex
        cache.delete cache_key(lex)
      end

      def expire_id id
        cache.delete id.to_s
      end

      def id_to_lex id
        cache.fetch id.to_s do
          result = Card.where(id: id).pluck(:name, :left_id, :right_id).first
          return unless result

          (result[0] || [result[1], result[2]]).tap do |lex|
            cache.write cache_key(lex), id
          end
        end
      end

      def name_to_lex name
        if name.simple?
          name
        elsif (left_id = id name.left_name) && (right_id = id name.right_name)
          [left_id, right_id]
        end
      end

      def lex_to_id lex
        cache.fetch cache_key(lex) do
          query = lex_query(lex).merge trash: false
          Card.where(query).pluck(:id).first.tap do |id|
            # don't store name, because lex might not be the canonical name
            cache.write id.to_s, lex if lex.is_a?(Array)
          end
        end
      end
    end
  end
end
