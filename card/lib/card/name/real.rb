class Card
  class Name
    module Real
      SQL = "SELECT id, cards.key, left_id, right_id from cards"
      ID_IDX = 0
      KEY_IDX = 1
      LEFT_IDX = 2
      RIGHT_IDX = 3

      def key id
        id_hash[id]
      end

      def id name
        key_hash[name.to_name.key]
      end

      def id_hash
        @id_hash ||= generate_id_hash
      end

      def key_hash
        @key_hash ||= id_hash.invert
      end

      private

      def generate_id_hash
        @id_hash = {}
        @holder = {}
        capture_simple_cards
        capture_compound_cards
        @id_hash
      end

      def raw_rows
        Card.connection.select_all(SQL).rows
      end

      def capture_simple_cards
        raw_rows.each do |r|
          # if r[KEY_IDX].present?
          if !r[LEFT_IDX]
            @id_hash[r[ID_IDX]] = r[KEY_IDX]
          else
            @holder[r[ID_IDX]] = [r[LEFT_IDX], r[RIGHT_IDX]]
          end
        end
      end

      def capture_compound_cards
        while still_finding_compounds? do
          @holder.each do |id, side_ids|
            next unless (key = compound_key side_ids)
            @id_hash[id] = key
          end
        end
      end

      def compound_key side_ids
        side_ids.map do |side_id|
          key = @id_hash[side_id]
          return false unless key
          key
        end.join joint
      end

      def still_finding_compounds?
        count = @holder.keys.count
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
