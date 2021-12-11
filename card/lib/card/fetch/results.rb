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
          assign_name mark
        end
        yield
      end

      def renew
        return if new_opts.blank?

        # Rails.logger.info "renewing: #{mark}, #{new_opts}"
        @card = card.dup
        @card.newish newish_opts
      end

      def newish_opts
        hash = new_opts.clone.reverse_merge name: mark
        if (content = assignable_content(hash.delete(:default_content)))
          hash[:content] = content
        end
        hash[:type_lookup] = :force if @force_type_lookup
        hash
      end

      def quick_renew
        return false unless quick_renew?

        update_supercard
        opts_name = new_opts[:name]
        assign_name(opts_name.present? ? opts_name : mark)
        true
      end

      def update_supercard
        return unless (sc = new_opts[:supercard])

        @card.supercard = sc
        @card.update_superleft
      end

      def quick_renew?
        return true if new_opts.blank?
        return false if type_change? || name_change?
        return false if fancy_renew?

        quick_content
        true
      end

      # contains subcards, etc, that quick_renew can't handle
      def fancy_renew?
        test_opts = new_opts.slice :supercard, :name, :type_id, :type, :type_code,
                                   :content, :default_content
        new_opts.keys.size > test_opts.keys.size
      end

      def assignable_content default_content
        new_opts[:content] || (@card.db_content.blank? && default_content)
      end

      def quick_content
        return unless (content = assignable_content(new_opts[:default_content]))

        @card.content = content
      end

      def name_change?
        return false unless (new_name = new_opts[:name]&.to_name)
        return false if new_name.relative? && mark.name? && mark.absolute?

        new_name.to_s != @card.name.to_s
      end

      def type_change?
        return true if @card.type_id.nil?

        type_id = type_id_from_new_opts
        return true if !type_id && supercard_might_change_type?

        type_id && (type_id != @card.type_id)
      end

      def type_id_from_new_opts
        type_id = new_opts[:type_id] || new_opts[:type] || new_opts[:type_code]&.to_sym
        type_id.is_a?(Symbol) ? Codename.id(type_id) : type_id
      end

      def supercard_might_change_type?
        # ...via type_plus_right rule
        sc = new_opts[:supercard]
        @force_type_lookup = sc&.new? && (sc.type_id != Card.default_type_id)
      end

      def new_opts
        @new_opts ||= opts[:new]
      end

      def assign_name requested
        return if opts[:local_only]
        return unless requested&.to_s != card.name

        card.name = requested.to_s
      end
    end
  end
end
