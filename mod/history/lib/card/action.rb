# -*- encoding : utf-8 -*-

class Card
  # An _action_ is a group of {Card::Change changes} to a single {Card card}
  # that is recorded during an {Card::Act act}.
  # Together, {Act acts}, {Action actions}, and {Change changes} comprise a
  # comprehensive {Card card} history tracking system.
  #
  # For example, if a given web submission changes both the name and type of
  # a given card, that would be recorded as one {Action action} with two
  # {Change changes}. If there are multiple cards changed, each card would
  # have its own {Action action}, but the whole submission would still comprise
  # just one single {Act act}.
  #
  # An {Action} records:
  #
  # * the _card_id_ of the {Card card} acted upon
  # *  the _card_act_id_ of the {Card::Act act} of which the action is part
  # * the _action_type_ (create, update, or delete)
  # * a boolean indicated whether the action is a _draft_
  # * a _comment_ (where applicable)
  #
  class Action < Cardio::Record
    include Differ
    include Changes
    extend Admin

    belongs_to :act, foreign_key: :card_act_id, inverse_of: :ar_actions
    belongs_to :ar_card, foreign_key: :card_id, inverse_of: :actions, class_name: "Card"
    has_many :card_changes, foreign_key: :card_action_id,
                            inverse_of: :action,
                            dependent: :delete_all,
                            class_name: "Card::Change"
    belongs_to :super_action, class_name: "Action", inverse_of: :sub_actions
    has_many :sub_actions, class_name: "Action", inverse_of: :super_action

    scope :created_by, lambda { |actor_id|
                         joins(:act).where "card_acts.actor_id = ?", actor_id
                       }

    # these are the three possible values for action_type
    TYPE_OPTIONS = %i[create update delete].freeze

    after_save :expire

    class << self
      # retrieve action from cache if available
      # @param id [id of Action]
      # @return [Action, nil]
      def fetch id
        cache.fetch id.to_s do
          where(id: id.to_i).take
        end
      end

      # cache object for actions
      # @return [Card::Cache]
      def cache
        Card::Cache[Action]
      end

      def all_with_cards
        joins :ar_card
      end

      def all_viewable
        all_with_cards.where Query::CardQuery.viewable_sql
      end
    end

    # sometimes Object#card_id interferes with default ActiveRecord attribute def
    def card_id
      _read_attribute "card_id"
    end

    # each action is associated with on and only one card
    # @return [Card]
    def card
      Card.fetch card_id, look_in_trash: true
    end

    # remove action from action cache
    def expire
      self.class.cache.delete id.to_s
    end

    # assign action_type (create, update, or delete)
    # @param value [Symbol]
    # @return [Integer]
    def action_type= value
      write_attribute :action_type, TYPE_OPTIONS.index(value)
    end

    # retrieve action_type (create, update, or delete)
    # @return [Symbol]
    def action_type
      return :draft if draft

      TYPE_OPTIONS[read_attribute(:action_type)]
    end

    def previous_action
      Card::Action.where("id < ? AND card_id = ?", id, card_id).last
    end

    def sole?
      all_changes.empty? &&
        (action_type == :create || Card::Action.where(card_id: card_id).count == 1)
    end
  end
end
