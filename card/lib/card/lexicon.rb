class Card
  module Lexicon
    # maintain hashes of real cards
    class << self
      def key id
        id_to_key[id]
      end

      def id name
        key_to_id[name.to_name.key]
      end

      def id_to_key
        @id_to_key ||= Card.cache.fetch("ID-TO-KEY") { generate_id_hash }
        # @id_to_key ||= generate_id_hash
      end

      def key_to_id
        @key_to_id ||= Card.cache.fetch("KEY-TO-ID") { id_to_key.invert }
        # @key_to_id ||= id_to_key.invert
      end

      def reset
        Card.cache.delete "ID-TO-KEY"
        Card.cache.delete "KEY-TO-ID"
        renew
      end

      def renew
        @id_to_key = nil
        @key_to_id = nil
        @holder = nil
        @holder_count = nil
      end

      def generate_id_hash
        @id_to_key = {}
        @holder = {}
        capture_simple_cards
        capture_compound_cards
        @id_to_key
      end

      def compound_key side_ids
        side_ids.map do |side_id|
          key side_id or return false
        end.join Card::Name.joint
      end

      def add id, key
        @id_to_key[id] = key
        @key_to_id[key] = id
        rewrite
      end

      private

      def rewrite
        Card.cache.write "ID-TO-KEY", @id_to_key
        Card.cache.write "KEY-TO-ID", @key_to_id
      end

      def raw_rows
        Card.pluck :id, :key, :left_id, :right_id
      end

      # record mapping of cards with simple names
      def capture_simple_cards
        raw_rows.each do |id, key, left_id, right_id|
          if !left_id
            @id_to_key[id] = key
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
        return unless (key = compound_key side_ids)
        @holder.delete id
        @id_to_key[id] = key
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
