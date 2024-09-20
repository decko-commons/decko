class Card
  class Reference < Cardio::Record
    module All
      # frozen_string_literal: true

      # Cards can refer to other cards in their content, eg via links and nests.
      # The card that refers is the "referer", the card that is referred to is
      # the "referee". The reference itself has its own class (Card::Reference),
      # which handles id-based reference tracking.

      PARTIAL_REF_CODE = "P".freeze

      # cards that refer to self
      def referers
        referer_cards_from_references references_in
      end

      # cards that include self
      def nesters
        referer_cards_from_references references_in.where(ref_type: "I")
      end

      def referer_cards_from_references references
        references.map(&:referer_id).uniq.map(&:card).compact
      end

      # cards that self refers to
      def referees
        referees_from_references references_out
      end

      # cards that self includes
      def nestees
        referees_from_references references_out.where(ref_type: "I")
      end

      def referees_from_references references
        references.map(&:referee_key).uniq.map { |key| Card.fetch key, new: {} }
      end

      # cards that refer to self by name
      # (finds cards not yet linked by id)
      def name_referers
        Card.joins(:references_out).where card_references: { referee_key: key }
      end

      # delete old references from this card's content, create new ones
      def update_references_out
        delete_references_out
        create_references_out
      end

      # interpret references from this card's content and
      # insert entries in reference table
      def create_references_out
        ref_hash = {}
        each_reference_out do |referee_name, ref_type|
          interpret_reference ref_hash, referee_name, ref_type
        end
        return if ref_hash.empty?

        Reference.insert_in_slices reference_values_array(ref_hash)
      end

      # replace references in card content
      def swap_names old_name, new_name
        cont = content_object
        cont.find_chunks(:Reference).each do |chunk|
          chunk.swap_name old_name, new_name
        end
        cont.to_s
      end

      private

      # interpretation phase helps to prevent duplicate references
      # results in hash like:
      # { referee1_key: [referee1_id, referee1_type2],
      #   referee2_key...
      # }
      def interpret_reference ref_hash, raw_referee_name, ref_type
        with_normalized_referee raw_referee_name do |name, key, id|
          ref_hash[key] ||= [id]
          ref_hash[key] << ref_type
          interpret_partial_references ref_hash, name unless id
        end
      end

      def with_normalized_referee referee_name
        return unless referee_name # eg commented nest has no referee_name

        referee_name = referee_name.to_name
        referee_key = referee_name.key
        return if referee_key == key # don't create self reference

        yield referee_name, referee_key, Lexicon.id(referee_name)
      end

      # translate interpreted reference hash into values array,
      # removing duplicate and unnecessary ref_types
      def reference_values_array ref_hash
        [].tap do |values|
          ref_hash.each do |referee_key, hash_val|
            referee_id = hash_val.shift
            each_reference_type hash_val.uniq do |ref_type|
              values << {
                referer_id: id,
                referee_id: referee_id,
                referee_key: referee_key,
                ref_type: ref_type
              }
            end
          end
        end
      end

      def each_reference_type ref_types, &block
        ref_types.delete PARTIAL_REF_CODE if ref_types.size > 1
        # partial references are not necessary if there are explicit references
        ref_types.each(&block)
      end

      # invokes the given block for each reference in content with
      # the reference name and reference type
      def each_reference_out
        content_object.find_chunks(:Reference).each do |chunk|
          yield chunk.referee_name, chunk.reference_code
        end
      end

      # Partial references are needed to track references to virtual cards.
      # For example a link to virtual card [[A+*self]] won't have a referee_id,
      # but when A's name is changed we have to find and update that link.
      def interpret_partial_references ref_hash, referee_name
        return if referee_name.simple?

        [referee_name.left, referee_name.right].each do |sidename|
          interpret_reference ref_hash, sidename, PARTIAL_REF_CODE
        end
      end
    end
  end
end
