class Card
  class Name
    module All
      # Card methods for finding name children, eg A+B is a child of A and B
      module Descendants
        # NOTE: for all these helpers, method returns *all* fields/children/descendants.
        # (Not just those current user has permission to read.)

        def fields
          field_ids.map { |id| Card[id] }
        end

        def field_names
          field_ids.map { |id| Card::Name[id] }
        end

        def field_ids
          child_ids :left
        end

        def each_child &block
          return unless id

          Card.where(
            "(left_id = #{id} or right_id = #{id}) and trash is false"
          ).each(&block)
        end

        # eg, A+B is a child of A and B
        def child_ids side=nil
          return [] unless id

          side ||= name.simple? ? :part : :left_id
          Auth.as_bot do
            Card.search({ side => id, return: :id, limit: 0 }, "children of #{name}")
          end
        end

        def each_descendant &block
          each_child do |child|
            yield child
            child.each_descendant(&block)
          end
        end
      end
    end
  end
end
