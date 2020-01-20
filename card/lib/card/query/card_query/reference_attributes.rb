class Card
  module Query
    class CardQuery
      # interpret CQL attributes that involve references from one card to another
      module ReferenceAttributes
        def self.define_reference_method methodname, reftype, ref_method, ref_field
          define_method methodname do |val|
            tie :reference,
                { ref_method => { reftype: reftype, card: val } },
                to: ref_field
          end
        end

        {
          refer_to: %w[L I],
          link_to: "L",
          include: "I",
          nest: "I"
        }.each do |methodname, reftype|
          define_reference_method methodname, reftype, :referee, :referer_id
        end

        {
          referred_to_by: %w[L I],
          linked_to_by: "L",
          included_by: "I",
          nested_by: "I"
        }.each do |methodname, reftype|
          define_reference_method methodname, reftype, :referer, :referee_id
        end

        # shortcut methods for role references
        # DEPRECATE?

        def member_of val
          interpret right_plus: [Card::RolesID, refer_to: val]
        end

        def member val
          interpret referred_to_by: { left: val, right: Card::RolesID }
        end
      end
    end
  end
end
