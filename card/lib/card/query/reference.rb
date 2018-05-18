class Card
  class Query
    class Reference < AbstractQuery

      DEFINITIONS = {
        # syntax:
        # wql query key => [ direction, {reference_type} ]
        # direction      = :out | :in
        # reference_type =  'L' | 'I' | 'P'

        refer_to: [:out, "L", "I"], referred_to_by: [:in, "L", "I"],
        link_to:  [:out, "L"],     linked_to_by:   [:in, "L"],
        include:  [:out, "I"],     included_by:    [:in, "I"]
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

      def full?
        false
      end

      def current_conjunction
        "AND"
      end

      def initialize statement
        super
        key = statement[:key]
        @val = statement[:val]
        direction, *reftype = DEFINITIONS[key.to_sym]
        @infield, @outfield = FIELDMAP[direction]
        add_reftype_conditions reftype
        infield_condition
        outfield_conditions
      end

      def infield_condition
        @conditions << "#{table_alias}.#{@infield} = #{@superquery.table_alias}.id"
      end

      def outfield_conditions
        if @val == "_none"
          non_outfield
        elsif (id = @superquery.id_from_val(@val))
          outfield_id id
        else
          outfield_join
        end
      end

      def non_outfield
        @conditions << "present = 0"
      end

      def outfield_id id
        @conditions << "#{table_alias}.#{@outfield} = #{id}"
      end

      def outfield_join
        subq = subquery
        subq.interpret @val
        subqueries << subq
        joins << Join.new(from: self, from_field: @outfield, to: subq)
      end

      def add_reftype_conditions reftype
        return unless reftype.present?
        operator = (reftype.size == 1 ? "=" : "IN")
        quoted_letters = reftype.map { |letter| "'#{letter}'" } * ", "
        @conditions << "ref_type #{operator} (#{quoted_letters})"
      end
    end

  end
end
