class Card
  class FollowerStash
    def initialize card=nil
      @followed_affected_cards = Hash.new { |h, v| h[v] = [] }
      @visited = ::Set.new
      add_affected_card(card) if card
    end

    def add_affected_card card
      return if @visited.include? card.key
      Auth.as_bot do
        @visited.add card.key
        notify_direct_followers card
        notify_field_followers card.left
      end
    end

    def followers
      @followed_affected_cards.keys
    end

    def each_follower_with_reason
      # "follower"(=user) is a card object, "followed"(=reasons) a card name
      @followed_affected_cards.each do |user, reasons|
        yield(user, reasons.first)
      end
    end

    private

    def notify_direct_followers card
      card.all_direct_follower_ids_with_reason do |user_id, reason|
        notify Card.fetch(user_id), of: reason
      end
    end

    def notify_field_followers card
      return unless (fields = notify_fields card)
      fields.each do |field|
        next unless visited?(field.to_name) || included?(card, field)
        add_affected_card card
        break
      end
    end

    def included? card, field
      return unless field.to_name.key == includes_card_key
      @visited.intersection(includee_set(card)).empty?
    end

    def includes_card_key
      @includes_card_key ||= :includes.cardname.key
    end

    def includee_set card
      @includee_set ||= {}
      @includee_set[card.key] ||= includee_search card
    end

    def includee_search card
      Card.search({ return: "key", included_by: card.name },
                  "follow cards included by #{card.name}")
    end

    def visited? name
      @visited.include? name.key
    end

    def notify_fields card
      return unless card && !visited?(card.name)
      card.rule_card(:follow_fields)&.item_names(context: card.name)
    end

    def notify follower, because
      @followed_affected_cards[follower] << because[:of]
    end
  end
end
