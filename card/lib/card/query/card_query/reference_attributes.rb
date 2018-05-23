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
          refer_to: ["L", "I"],
          link_to:  "L",
          include:  "I"
        }.each do |methodname, reftype|
          define_reference_method methodname, reftype, :referee, :referer_id
        end

        {
          referred_to_by: [:in, "L", "I"],
          linked_to_by:   [:in, "L"],
          included_by:    [:in, "I"]
        }.each do |methodname, reftype|
          define_reference_method methodname, reftype, :referer, :referee_id
        end
      end
    end
  end
end
