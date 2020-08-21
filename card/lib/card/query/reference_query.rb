class Card
  module Query
    # support the use of the card_references table in CQL
    class ReferenceQuery < AbstractQuery
      def table
        "card_references"
      end

      def table_prefix
        "cr"
      end

      def referer hash
        add_conditions :referer_id, hash
      end

      def referee hash
        add_conditions :referee_id, hash
      end

      def add_conditions outfield, hash
        add_reftype_condition hash[:reftype]
        add_outfield_condition outfield, hash[:card]
      end

      def add_outfield_condition outfield, outcard
        if outcard == "_none"
          non_outfield
        elsif (id = id_from_val(outcard))
          outfield_id outfield, id
        else
          tie :card, outcard, from: outfield
        end
      end

      def non_outfield
        add_condition "#{fld :is_present} = 0"
      end

      def outfield_id outfield, id
        add_condition "#{fld(outfield)} = #{id}"
      end

      def add_reftype_condition reftype
        return unless reftype.present?

        reftype = Array.wrap reftype
        operator = (reftype.size == 1 ? "=" : "IN")
        quoted_letters = reftype.map { |letter| "'#{letter}'" } * ", "
        add_condition "#{fld(:ref_type)} #{operator} (#{quoted_letters})"
      end
    end
  end
end
