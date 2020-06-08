class Card
  class Fetch
    # polishing fetch results
    module Results
      def results
        return if card.nil?
        card.new_card? ? new_result_card : finalize_result_card
      end

      def finalize_result_card
        card.include_set_modules unless skip_modules?
        card
      end

      def new_result_card
        if (new_opts = opts[:new])
          if new_opts.present?
            Rails.logger.info "renewing: #{mark}, #{new_opts}"

            @card = card.renew mark, new_opts
          end
        elsif opts[:skip_virtual]
          return nil
        else
          assign_name_from_mark
        end
        finalize_result_card
        # must include_set_modules before checking `card.known?`,
        # in case, eg, set modules override #virtual?
        card if new_opts || card.known?
      end

      def assign_name_from_mark
        return if opts[:local_only]
        return unless mark&.to_s != card.name
        card.name = mark.to_s
      end
    end
  end
end
