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
        with_new_card do
          finalize_result_card
          # must include_set_modules before checking `card.known?`,
          # in case, eg, set modules override #virtual?
          card if new_opts || card.known?
        end
      end

      def with_new_card
        if new_opts
          quick_renew || renew
        elsif opts[:skip_virtual]
          return nil
        else
          assign_name_from_mark
        end
        yield
      end

      def renew
        # Rails.logger.info "renewing: #{mark}, #{new_opts}"
        @card = card.dup
        @card.newish newish_opts
      end

      def newish_opts
        hash = new_opts.clone.reverse_merge name: mark
        if (default_content = hash.delete(:default_content)) && @card.db_content.blank?
          hash[:content] ||= default_content
        end
        hash
      end

      def quick_renew
        return false unless quick_renew?
        # Rails.logger.info "QUICK renewing: #{mark}, #{new_opts}"

        update_supercard
        assign_name_from_mark
        true
      end

      def update_supercard
        return unless (sc = new_opts[:supercard])
        @card.supercard = sc
        @card.update_superleft @card.name
      end

      def quick_renew?
        return false if type_change? || name_change?
        test_opts = new_opts.slice :supercard, :name, :type_id, :type
        new_opts.keys.size <= test_opts.keys.size
      end

      def name_change?
        new_name = new_opts[:name]&.to_name
        (new_name && (new_name != @card.name)) #  || @card.name.relative?
      end

      def type_change?
        return true unless @card.type_id
        type_id = new_opts[:type_id] || new_opts[:type]
        type_id = Codename.id(type_id) if type_id.is_a? Symbol
        type_id && (type_id != @card.type_id)
      end

      def new_opts
        @new_opts ||= opts[:new]
      end

      def assign_name_from_mark
        return if opts[:local_only]
        return unless mark&.to_s != card.name
        card.name = mark.to_s
      end
    end
  end
end
