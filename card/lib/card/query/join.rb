class Card
  module Query
    # object representation of Card::Query joins
    class Join
      JOIN_OPT_KEYS = %i[side conditions
                         from from_table from_alias from_field
                         to to_table to_alias to_field].freeze
      attr_accessor(*JOIN_OPT_KEYS)

      # These two manage hierarchy of nested joins
      attr_accessor :superjoin, :subjoins

      # This example join clause:
      #
      #   cards c LEFT JOIN card_actions ca on c.id = ca.card_id and ca.draft is null
      #
      # ...would translate into the following instance variables on the Join object:
      #
      #   @side = "left"
      #   @from_table = "cards"
      #   @from_alias = "c"
      #   @from_field = "id"
      #   @to_table = "card_actions"
      #   @to_alias = "ca"
      #   @to_field = "card_id"
      #   @conditions = "ca.draft is null"
      #
      # all of the above can be set directly via opts using the keys with the same name.
      #
      #   Join.new side: "left", from_table: "cards"...
      #
      # The from and to fields can also be set via :from and :to keys.
      # (see #interpret_from_and_to)
      #
      # You can generally use Symbols in place of Strings where applicable.
      #
      def initialize opts={}
        interpret_from_and_to opts
        convert_opts_to_instance_variables opts

        @conditions = Array(@conditions).compact
        @subjoins = []
        register_superjoin
      end

      def side
        if !@side.nil?
          @side.to_s.upcase
        else
          in_or = from&.is_a?(Card::Query) && from.mods[:conj] == "or"
          @side = in_or ? "LEFT" : nil
        end
      end

      def left?
        side == "LEFT"
      end

      private

      # the options :to and :from can be translated into the full table/alias/field trio.
      #
      # - An Array is interpreted in that order (table, alias, field)
      # - A Hash expects the keys :table, :alias, and (optionally) :field
      # - A table and alias can be inferred from Card::Query or Card::Query::Reference
      #   objects.
      # - They can also be inferred from a Join object, but only as a :from value
      #
      # In all cases, if the field is not specified, it is assumed to be :id
      def interpret_from_and_to opts
        %i[from to].each do |side|
          directional_hash_for_object(side, opts[side]).map do |key, value|
            opts[:"#{side}_#{key}"] ||= value
          end
        end
      end

      def directional_hash_for_object side, object
        case object
        when nil              then nil
        when Hash             then object
        when Array            then dir_hash(*object)
        when AbstractQuery    then dir_hash_for_query object
        when Join             then dir_hash_for_join side, object
        else                       dir_error(side, object)
        end
      end

      def dir_hash table, table_alias, field=nil
        hash = { table: table, alias: table_alias }
        hash[:field] = field || :id
        hash
      end

      def dir_hash_for_query query
        dir_hash query.table, query.table_alias
      end

      def dir_hash_for_join side, object
        raise "to: cannot be Join" if side == :to

        dir_hash object.to_table, object.to_alias
      end

      def dir_error side, object
        raise Card::Error::BadQuery, "invalid #{side} option: #{object}"
      end

      def convert_opts_to_instance_variables opts
        opts.each do |key, value|
          send "#{key}=", value if value.present? && JOIN_OPT_KEYS.member?(key)
        end
      end

      def register_superjoin
        return unless @from.is_a? Join

        @superjoin = @from
        @superjoin.subjoins << self
      end
    end
  end
end
