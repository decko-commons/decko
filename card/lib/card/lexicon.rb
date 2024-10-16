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

      def write_to_temp_cache id, name, lex
<<<<<<< HEAD
        write cache.temp, id, name, lex
      end

      def update card
        lex = card.lex
        add_to_act card, lex
        if card.trash
          delete card
        else
          expire_lex card.lex_before_act if card.action == :update
          write cache, card.id, card.name, lex
        end
      end

      private

      def delete card
        cache.write card.id.to_s, nil
        cache.write cache_key(card.lex_before_act), nil
      end

      def write cache_klass, id, name, lex
        cache_klass.write id.to_s, name if id.present?
        cache_klass.write cache_key(lex), id if lex
      end

      def add_to_act card, lex
        @act_lexes << lex
        @act_ids << card.id
      end

      def expire_lex lex
        cache.delete cache_key(lex)
      end

      def expire_id id
        cache.delete id.to_s
      end

      def id_to_lex id
        cache.fetch(id.to_s) do
          card_by_id(id)&.lex
        end
      end

      def lex_to_id lex
        key = cache_key lex
        cache.fetch(key) do
          card_by_lex(lex)&.id
        end
      end

      def name_to_lex name
        if name.simple?
          name
        elsif (left_id = id name.left_name) && (right_id = id name.right_name)
          [left_id, right_id]
        end
      end

      def card_by_id id
        cache_card id: id, trash: false
      end

      def card_by_lex lex
        cache_card lex_query(lex).merge(trash: false)
      end

      def cache_card query
        # card =
        Card.where(query).take
        # return unless ()
        # card.tap do |card|
        #   Card.cache.temp.fetch(card.key, callback: false) { card }
        #   card.write_lexicon
        # end
      end
    end
  end
end
