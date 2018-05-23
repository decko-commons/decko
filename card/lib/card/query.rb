# -*- encoding : utf-8 -*-

class Card
  # Card::Query is for finding implicit lists (or counts of lists) of cards.
  #
  # Search and Set cards use Card::Query to query the database, and it's also
  # frequently used directly in code.
  #
  # Query "statements" (objects, really) are made in WQL (Wagn Query
  # Language). Because WQL is used by Deckers, the primary language
  # documentation is on wagn.org. (http://wagn.org/WQL_Syntax). Note that the
  # examples there are in JSON, like Search card content, but statements in
  # Card::Query are in ruby form.
  #
  # In Decko's current form, Card::Query generates and executes SQL statements.
  # However, the SQL generation is largely (not yet fully) separated from the
  # WQL statement interpretation.
  #
  # The most common way to use Card::Query is as follows:
  #     list_of_cards = Card::Query.run(statement)
  #
  # This is equivalent to:
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
  #    [ field_string_or_sym, Card::Value::Query object ]
  module Query
    require_dependency "card/query/card_query"

    ATTRIBUTES = {
      basic:           %w(id name key type_id content left_id right_id
                          creator_id updater_id codename read_rule_id),
      relational:      %w(type part left right
                          editor_of edited_by last_editor_of last_edited_by
                          creator_of created_by member_of member
                          updater_of updated_by),
      plus_relational: %w(plus left_plus right_plus),
      ref_relational:  %w(refer_to referred_to_by
                          link_to linked_to_by
                          include included_by),
      conjunction:     %w(and or all any),
      special:         %w(found_by not sort match name_match complete
                          junction_complete extension_type),
      ignore:          %w(prepend append view params vars size)
    }.each_with_object({}) do |pair, h|
      pair[1].each { |v| h[v.to_sym] = pair[0] }
    end

    CONJUNCTIONS = { any: :or, in: :or, or: :or, all: :and, and: :and }.freeze

    MODIFIERS = %w(conj return sort sort_as group dir limit offset)
                .each_with_object({}) { |v, h| h[v.to_sym] = nil }

    OPERATORS =
      %w(!= = =~ < > in ~).each_with_object({}) { |v, h| h[v] = v }.merge(
        {
          eq: "=", gt: ">", lt: "<", match: "~", ne: "!=", "not in": "not in"
        }.stringify_keys
      )

    DEFAULT_ORDER_DIRS = { update: "desc", relevance: "desc" }.freeze

    class << self
      def new statement, comment=nil
        Query::CardQuery.new statement, comment
      end

      def run statement, comment=nil
        new(statement, comment).run
      end
    end
  end
end
