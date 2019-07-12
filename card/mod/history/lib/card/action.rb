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
  class Action < ApplicationRecord
    include Card::Action::Differ
    extend Card::Action::Admin

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
          find id.to_i
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

    # each action is associated with on and only one card
    # @return [Card]
    def card
      Card.fetch card_id, look_in_trash: true

      # I'm not sure what the rationale for the following was/is, but it was causing
      # problems in cases where slot attributes are overridden (eg see #wrap_data in
      # sources on wikirate).  The problem is the format object had the set modules but
      # the card didn't.
      #
      # My guess is that the need for the following had something to do with errors
      # associated with changed types. If so, the solution probably needs to handle
      # including the set modules associated with the type at the time of the action
      # rather than including no set modules at all.
      #
      # What's more, we _definitely_ don't want to hard code special behavior for
      # specific types in here!

      # , skip_modules: true
      # return res unless res && res.type_id.in?([FileID, ImageID])
      # res.include_set_modules
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

    # value set by action's {Change} to given field
    # @see #interpret_field #interpret_field for field param
    # @see #interpret_value #interpret_value for return values
    def value field
      return unless (change = change field)

      interpret_value field, change.value
    end

    # value of field set by most recent {Change} before this one
    # @see #interpret_field #interpret_field for field param
    # @see #interpret_field  #interpret_field for field param
    def previous_value field
      return if action_type == :create
      return unless (previous_change = previous_change field)

      interpret_value field, previous_change.value
    end

    # action's {Change} object for given field
    # @see #interpret_field #interpret_field for field param
    # @return [Change]
    def change field
      changes[interpret_field field]
    end

    # most recent change to given field before this one
    # @see #interpret_field #interpret_field for field param
    # @return [Change]
    def previous_change field
      return nil if action_type == :create

      field = interpret_field field
      if @previous_changes&.key?(field)
        @previous_changes[field]
      else
        @previous_changes ||= {}
        @previous_changes[field] = card.last_change_on field, before: self
      end
    end

    def all_changes
      self.class.cache.fetch("#{id}-changes") do
        card_changes.find_all.to_a
      end
    end

    # all action {Change changes} in hash form. { field1: Change1 }
    # @return [Hash]
    def changes
      @changes ||=
        if sole?
          current_changes
        else
          all_changes.each_with_object({}) do |change, hash|
            hash[change.field.to_sym] = change
          end
        end
    end

    # all changed values in hash form. { field1: new_value }
    def changed_values
      @changed_values ||= changes.each_with_object({}) do |(key, change), h|
        h[key] = change.value
      end
    end

    # @return [Hash]
    def current_changes
      return {} unless card

      @current_changes ||=
        Card::Change::TRACKED_FIELDS.each_with_object({}) do |field, hash|
          hash[field.to_sym] = Card::Change.new field: field,
                                                value: card.send(field),
                                                card_action_id: id
        end
    end

    # translate field into fieldname as referred to in database
    # @see Change::TRACKED_FIELDS
    # @param field [Symbol] can be :type_id, :cardtype, :db_content, :content,
    #     :name, :trash
    # @return [Symbol]
    def interpret_field field
      case field
      when :content then :db_content
      when :cardtype then :type_id
      else field.to_sym
      end
    end

    # value in form prescribed for specific field name
    # @param value [value of {Change}]
    # @return [Integer] for :type_id
    # @return [String] for :name, :db_content, :content, :cardtype
    # @return [True/False] for :trash
    def interpret_value field, value
      case field.to_sym
      when :type_id
        value&.to_i
      when :cardtype
        Card.fetch_name(value&.to_i)
      else value
      end
    end

    def sole?
      all_changes.empty? &&
        (action_type == :create || Card::Action.where(card_id: card_id).count == 1)
    end
  end
end
