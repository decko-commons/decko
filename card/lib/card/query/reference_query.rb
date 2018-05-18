class Card
  class Query
    def refer key, val
      subquery class: ReferenceQuery, fasten: :exist, key => val
    end

    class ReferenceQuery < AbstractQuery

      RELATIONSHIPS = {
        # syntax:
        # wql query key => [ direction, {reference_type} ]
        # direction      = :out | :in
        # reference_type =  'L' | 'I' | 'P'

        refer_to: [:out, "L", "I"], referred_to_by: [:in, "L", "I"],
        link_to:  [:out, "L"],      linked_to_by:   [:in, "L"],
        include:  [:out, "I"],      included_by:    [:in, "I"]
      }.freeze

      FIELDMAP = {
        out: [:referer_id, :referee_id],
        in:  [:referee_id, :referer_id]
      }.freeze

      def table
        "card_references"
      end

      def table_prefix
        "cr"
      end

      def initialize statement
        super
        @statement.each do |relationship, outcard|
          direction, *reftype = RELATIONSHIPS[relationship.to_sym]
          infield, outfield = FIELDMAP[direction]
          add_reftype_condition reftype
          add_infield_condition infield
          add_outfield_condition outfield, outcard
        end
      end

      def add_infield_condition infield
        superfield infield, :id
      end

      def add_outfield_condition outfield, outcard
        if outcard == "_none"
          non_outfield
        elsif (id = id_from_val(outcard))
          outfield_id outfield, id
        else
          exists_card outcard, id: outfield
        end
      end

      def non_outfield
        add_condition "#{fld :present} = 0"
      end

      def outfield_id outfield, id
        add_condition "#{fld(outfield)} = #{id}"
      end

      def add_reftype_condition reftype
        return unless reftype.present?
        operator = (reftype.size == 1 ? "=" : "IN")
        quoted_letters = reftype.map { |letter| "'#{letter}'" } * ", "
        add_condition "ref_type #{operator} (#{quoted_letters})"
      end
    end
  end
end
