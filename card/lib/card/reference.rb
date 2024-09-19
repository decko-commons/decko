# -*- encoding : utf-8 -*-

class Card
  # a Reference is a directional relationship from one card (the referer)
  # to another (the referee).
  class Reference < Cardio::Record
    # card that refers
    def referer
      Card[referer_id]
    end

    # card that is referred to
    def referee
      Card[referee_id]
    end

    class << self
      # bulk insert improves performance considerably
      # array takes form [ [referer_id, referee_id, referee_key, ref_type], ...]
      def mass_insert array
        array.each_slice(5000) do |slice|
          insert_all mass_insert_values(slice)
        end
      end

      # map existing reference to name to card via id
      def map_referees referee_key, referee_id
        where(referee_key: referee_key).update_all referee_id: referee_id
      end

      # references no longer refer to card, so remove id
      def unmap_referees referee_id
        where(referee_id: referee_id).update_all referee_id: nil
      end

      # remove reference to and from missing cards
      def clean
        missing(:referee_id).where("referee_id IS NOT NULL").update_all referee_id: nil
        missing(:referer_id).pluck_in_batches(:id) do |group_ids|
          # used to be .delete_all here, but that was failing on large dbs
          Rails.logger.info "deleting batch of references"
          where("id in (#{group_ids.join ','})").delete_all
        end
      end

      # repair references one by one (delete, create, delete, create...)
      # slower, but better than #recreate_all for use on running sites
      def repair_all
        clean
        each_card(&:update_references_out)
      end

      # delete all references, then recreate them one by one
      # faster than #repair_all, but not recommended for use on running sites
      def recreate_all
        delete_all
        each_card(&:create_references_out)
      end

      private

      # find all references to or from missing (eg deleted) cards
      def missing field
        joins("LEFT JOIN cards ON card_references.#{field} = cards.id")
          .where("(cards.id IS NULL OR cards.trash IS TRUE)")
      end

      def each_card
        Card.where(trash: false).find_each do |card|
          Rails.logger.debug "references from #{card.name}"
          yield card.include_set_modules
        end
      end

      def mass_insert_values slice
        [].tap do |values|
          slice.each do |v|
            values << {
              referer_id: v[0],
              referee_id: v[1],
              referee_key: v[2],
              ref_type: v[3]
            }
          end
        end
      end
    end
  end
end
