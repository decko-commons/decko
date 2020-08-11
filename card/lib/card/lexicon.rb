class Card
  module Lexicon
    # Translates keys to ids and vice versa via an intermediate "lex" representation
    # Note: the lexicon does NOT distinguish between trashed and untrashed cards.
    #
    # The lex representation
    class << self
      # param id [Integer]
      # @return [String]
      def key id
        lex_to_key id_to_lex[id]
      end

      def lex_to_key lex
        return lex unless lex&.is_a? Array
        lex.map { |side_id| key side_id }.join Card::Name.joint
      end

      # param name [String]
      # @return [Integer]
      def id name
        return unless (lex = name_to_lex name)

        lex_to_id[lex]
      end

      def name_to_lex name
        name = name.to_name
        return name.key if name.simple?
        return unless (left_id = id name.left_name) && (right_id = id name.right_name)
        [left_id, right_id]
      end

      # @return [Hash] { cardid1 => cardkey1, ...}
      def id_to_lex
        @id_to_lex ||= Card.cache.fetch("ID-TO-LEX") { generate_id_hash }
        # @id_to_lex ||= generate_id_hash
      end

      # @return [Hash] { cardkey1 => cardid1, ...}
      def lex_to_id
        @lex_to_id ||= Card.cache.fetch("LEX-TO-ID") { id_to_lex.invert }
        # @lex_to_id ||= id_to_lex.invert
      end

      def reset
        Card.cache.delete "ID-TO-LEX"
        Card.cache.delete "LEX-TO-ID"
        renew
      end

      def renew
        @id_to_lex = nil
        @lex_to_id = nil
      end

      def generate_id_hash
        @holder = {}
        @holder_count = nil
        @simple = {}
        @compound = {}
        capture_simple_cards
        capture_compound_cards
        @id_to_lex = @simple.merge @compound
        @simple = nil
        @compound = nil
        @id_to_lex
      end

      def add card
        lex = card.lex
        @id_to_lex[card.id] = lex
        @lex_to_id[lex] = card.id
        rewrite # TODO: rewrite only once per act
      end

      def update card
        @id_to_lex[card.id] = card.lex
        # cascade_update descendant_idsans
        @lex_to_id = @id_to_lex.invert
        rewrite
      end

      def compound_key side_ids
        side_ids.map do |side_id|
          key side_id or return false
        end.join Card::Name.joint
      end

      private

      def rewrite
        Card.cache.write "ID-TO-LEX", @id_to_lex
        Card.cache.write "LEX-TO-ID", @lex_to_id
      end

      def raw_rows
        Card.pluck :id, :key, :left_id, :right_id
      end

      # record mapping of cards with simple names
      def capture_simple_cards
        raw_rows.each do |id, key, left_id, right_id|
          if !left_id
            @simple[id] = key
          else
            @holder[id] = [left_id, right_id]
          end
        end
      end

      def capture_compound_cards
        while still_finding_compounds?
          @holder.each do |id, side_ids|
            capture_compound_card id, side_ids
          end
        end
      end

      def capture_compound_card id, side_ids
        @compound[id] = side_ids
        @holder.delete id
      end

      def still_finding_compounds?
        count = @holder.size
        return false if count.zero?
        if @holder_count.nil? || (@holder_count > count)
          @holder_count = count
        else
          Rails.logger.info "could not interpret cards: #{@holder}"
          false
        end
      end
    end
  end
end
