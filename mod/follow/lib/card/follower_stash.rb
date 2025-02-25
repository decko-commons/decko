class Card
  # stash followers of a given card
  class FollowerStash
    def initialize card=nil
      @stash = Hash.new { |h, v| h[v] = [] }
      @checked = ::Set.new
      check_card(card) if card
    end

    def check_card card
      return if @checked.include? card.key

      Auth.as_bot do
        @checked.add card.key
        stash_direct_followers card
        stash_field_followers card.left
      end
    end

    def followers
      @stash.keys
    end

    def each_follower_with_reason
      # "follower"(=user) is a card object, "followed"(=reasons) a card name
      @stash.each do |follower_card, reasons|
        yield(follower_card, reasons.first)
      end
    end

    private

    def stash_direct_followers card
      card.each_direct_follower_id_with_reason do |user_id, reason|
        stash Card.fetch(user_id), reason
      end
    end

    def stash_field_followers card
      return unless (fields = follow_fields card)

      fields.each do |field|
        break if stash_field_follower card, field
      end
    end

    def stash_field_follower card, field
      return false unless checked?(field.to_name) || nested?(card, field)

      check_card card
      true
    end

    def nested? card, field
      return false unless field.to_name.key == includes_card_key

      @checked.intersection(nestee_set(card)).any?
    end

    def includes_card_key
      @includes_card_key ||= :nests.cardname.key
    end

    def nestee_set card
      @nestee_set ||= {}
      @nestee_set[card.key] ||= nestee_search card
    end

    def nestee_search card
      Card.search({ return: "key", included_by: card.name },
                  "follow cards included by #{card.name}")
    end

    def checked? name
      @checked.include? name.key
    end

    def follow_fields card
      return unless card && !checked?(card.name)

      card.rule_card(:follow_fields)&.item_names(context: card.name)
    end

    def stash follower, reason
      @stash[follower] << reason
    end
  end
end
