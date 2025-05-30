# -*- encoding : utf-8 -*-

class Card
  # Card::Query is for finding implicit lists (or counts of lists) of cards.
  #
  # Search and Set cards use Card::Query to query the database, and it's also
  # frequently used directly in code.
  #
  # Query "statements" (objects, really) are made in CQL (Card Query
  # Language). Because CQL is used by Sharks, [the primary CQL Syntax documentation is
  # on decko.org](https://decko.org/CQL_Syntax). Note that the
  # examples there are in JSON, like Search card content, but statements in
  # Card::Query are in ruby form.
  #
  # In Decko's current form, Card::Query generates and executes SQL statements.
  # However, the SQL generation is largely (not yet fully) separated from the
  # CQL statement interpretation.
  #
  # The most common way to use Card::Query is as follows:
  #
  #     list_of_cards = Card::Query.run(statement)
  #
  # This is equivalent to:
  #
  #     query = Card::Query.new(statement)
  #     list_of_cards = query.run
  #
  # Upon initiation, the query is interpreted, and the following key objects
  # are populated:
  #
  # - @join - an Array of Card::Query::Join objects
  # - @conditions - an Array of conditions
  # - @mod - a Hash of other query-altering keys
  # - @subqueries - a list of other queries nested within this one
  #
  # Each condition is either a SQL-ready string (boo) or an Array in this form:
  #
  #     [field_string_or_sym, (Card::Value::Query object)]
  module Query
    require "card/query/clause"
    require "card/query/card_query"
    require "card/query/sql_statement"

    # Card::Query::CardQuery
    # After conversion, @attributes is a Hash where the key is the attribute
    # and the value is the attribute type:
    # { id: :basic, name: :basic, key: :basic ...}
    # This is used for rapid attribute type lookups in the interpretation phase.
    @attributes = {
      # Each of the "basic" fields corresponds directly to a database field.
      # their values are translated fairly directly into SQL-safe values.
      # (These are referred to as "properties" in CQL documentation. Need to
      # reconcile #EFM)
      basic: %i[id name key type_id content left_id right_id codename read_rule_id
                created_at updated_at creator_id updater_id ],
      # "Relational" values can involve tying multiple queries together
      relational: %i[type
                     part left right
                     editor_of edited_by last_editor_of last_edited_by
                     creator_of created_by
                     updater_of updated_by
                     link_to linked_to_by
                     include included_by
                     nest nested_by

                     refer_to referred_to_by
                     member_of member

                     found_by
                     not sort match name_match complete],

      plus_relational: %i[plus left_plus right_plus],
      conjunction: %i[and or all any],
      custom: [:compound],
      ignore: %i[prepend append vars],
      deprecated: %i[view params size]
    }.each_with_object({}) do |pair, h|
      pair[1].each { |v| h[v] = pair[0] }
    end

    CONJUNCTIONS = { any: :or, in: :or, or: :or, all: :and, and: :and }.freeze

    # "dir" is DEPRECATED in favor of sort_dir
    # "sort" is DEPRECATED in favor of sort_by, except in cases where sort's value
    # is a hash
    MODIFIERS = %i[conj return index sort_by sort_as sort_dir sort dir group limit offset]
                .each_with_object({}) { |v, h| h[v] = nil }

    OPERATORS =
      %w[!= = =~ < > in ~ is].each_with_object({}) { |v, h| h[v] = v }.merge(
        { eq: "=", gt: ">", lt: "<", match: "~", ne: "!=",
          "not in": "not in", "is not": "is not", "!": "is not" }.stringify_keys
      )

    DEFAULT_ORDER_DIRS = { update: "desc", relevance: "desc" }.freeze

    class << self
      attr_accessor :attributes

      def new statement, comment=nil
        Query::CardQuery.new statement, comment
      end

      def run statement, comment=nil
        new(statement, comment).run
      end

      def class_for type
        const_get "#{type.capitalize}Query"
      end

      def safe_sql txt
        txt = txt.to_s
        raise "CQL contains disallowed characters: #{txt}" if txt.match?(/[^\w\s*().,]/)

        txt
      end
    end

    delegate :attributes, to: :class
  end
end
