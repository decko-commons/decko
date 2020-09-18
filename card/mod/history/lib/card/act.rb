# -*- encoding : utf-8 -*-

class Card
  # An "act" is a group of recorded {Card::Action actions} on {Card cards}.
  # Together, {Act acts}, {Action actions}, and {Change changes} comprise a
  # comprehensive {Card card} history tracking system.
  #
  # For example, if a given web form submissions updates the contents of three cards,
  # then the submission will result in the recording of three {Action actions}, each
  # of which is tied to one {Act act}.
  #
  # Each act records:
  #
  # - the _actor_id_ (an id associated with the account responsible)
  # - the _card_id_ of the act's primary card
  # - _acted_at_, a timestamp of the action
  # - the _ip_address_ of the actor where applicable.
  #
  class Act < ApplicationRecord
    before_save :assign_actor
    has_many :ar_actions, -> { order :id }, foreign_key: :card_act_id,
                                            inverse_of: :act,
                                            class_name: "Card::Action"
    class << self
      # remove all acts that have no card. (janitorial)
      #
      # CAREFUL - could still have actions even if act card is gone...
      def delete_cardless
        left_join = "LEFT JOIN cards ON card_acts.card_id = cards.id"
        joins(left_join).where("cards.id IS NULL").delete_all
      end

      # remove all acts that have no action. (janitorial)
      def delete_actionless
        joins(
          "LEFT JOIN card_actions ON card_acts.id = card_act_id"
        ).where(
          "card_actions.id is null"
        ).delete_all
      end

      # all acts with actions on a given list of cards
      # @param card_ids [Array of Integers]
      # @param with_drafts [true, false] (only shows drafts of current user)
      # @return [Array of Acts]
      def all_with_actions_on card_ids, with_drafts=false
        sql = "card_actions.card_id IN (:card_ids) AND (draft is not true"
        sql << (with_drafts ? " OR actor_id = :user_id)" : ")")
        all_viewable([sql, { card_ids: card_ids, user_id: Card::Auth.current_id }])
      end

      # all acts with actions that current user has permission to view
      # @return [ActiveRecord Relation]
      # ARDEP: Relation
      def all_viewable action_where=nil
        relation = joins(ar_actions: :ar_card)
        relation = relation.where(action_where) if action_where
        relation.where(Query::CardQuery.viewable_sql).where.not(card_id: nil).distinct
      end

      def cache
        Card::Cache[Card::Act]
      end

      # used by rails time_ago
      # timestamp is set by rails on create
      def timestamp_attributes_for_create
        super << "acted_at"
      end
    end

    def actor
      Card.fetch actor_id
    end

    # the act's primary card
    # @return [Card]
    def card
      Card.fetch card_id, look_in_trash: true # , skip_modules: true

      # FIXME: if the following is necessary, we need to document why.
      # generally it's a very bad idea to have type-specific code here.

      # return res unless res&.type_id&.in?([Card::FileID, Card::ImageID])
      # res.include_set_modules
    end

    # list of all actions that are part of the act
    # @return [Array]
    def actions cached=true
      return ar_actions unless cached

      self.class.cache.fetch("#{id}-actions") { ar_actions.find_all.to_a }
    end

    # act's action on the card in question
    # @param card_id [Integer]
    # @return [Card::Action]
    def action_on card_id
      actions.find do |action|
        action.card_id == card_id && !action.draft
      end
    end

    # act's action on primary card if it exists. otherwise act's first action
    # @return [Card::Action]
    def main_action
      action_on(card_id) || actions.first
    end

    def draft?
      main_action.draft
    end

    # time (in words) since act took place
    # @return [String]
    def elapsed_time
      DateTime.new(acted_at).distance_of_time_in_words_to_now
    end

    # act's actions on either the card itself or another card that includes it
    # @param card [Card]
    # @return [Array of Actions]
    def actions_affecting card
      actions.select do |action|
        (card.id == action.card_id) ||
          card.nestee_ids.include?(action.card_id)
      end
    end

    private

    # used by before filter
    def assign_actor
      self.actor_id ||= Auth.current_id
    end
  end
end
