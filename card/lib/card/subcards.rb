# -*- encoding : utf-8 -*-

class Card
  # API to create/update/delete additional cards together with the main card.
  # The most common case is for fields but subcards don't have to be descendants.
  #
  # Subcards can be added as card objects or attribute hashes.
  #
  # Use the methods defined in core/set/all/subcards.rb
  # Example
  # Together with "my address" you want to create the subcards
  # "my address+name", "my address+street", etc.
  class Subcards
    include Add
    include Remove
    include Relate

    attr_accessor :context_card, :keys

    def initialize context_card
      @context_card = context_card
      @keys = ::Set.new
    end

    def [] name
      card(name) || field(name)
    end

    def field name
      key = field_name_to_key name
      fetch_subcard key if @keys.include? key
    end

    def card name
      return unless @keys.include? name.to_name.key

      fetch_subcard name
    end

    def present?
      @keys.present?
    end

    def catch_up_to_stage stage_index
      each_card do |subcard|
        subcard.catch_up_to_stage stage_index
      end
    end

    def rename old_name, new_name
      return unless @keys.include? old_name.to_name.key

      @keys.delete old_name.to_name.key
      @keys << new_name.to_name.key
    end

    def respond_to_missing? method_name, _include_private=false
      @keys.respond_to? method_name
    end

    def method_missing(method, *)
      return unless respond_to_missing?(method)

      @keys.send(method, *)
    end

    # fetch all cards first to avoid side effects
    # e.g. deleting a user adds follow rules and +*account to subcards
    # for deleting but deleting follow rules can remove +*account from the
    # cache if it belongs to the rule cards
    def cards
      @keys.map do |key|
        fetch_subcard key
      end.compact
    end

    def each_card(&)
      cards.each(&)
    end

    alias_method :each, :each_card

    def each_with_key
      @keys.each do |key|
        card = fetch_subcard(key)
        yield(card, key) if card
      end
    end

    def fetch_subcard key
      Card.fetch key, local_only: true, new: {}
    end

    private

    def subcard_key cardish
      key = case cardish
            when Card   then cardish.key
            when Symbol then fetch_subcard(cardish).key
            else             cardish.to_name.key
            end
      key = absolutize_subcard_name(key).key unless @keys.include?(key)
      key
    end

    def absolutize_subcard_name name
      name = Card::Name[name]
      return name if @context_card.name.parts.first.blank?

      name.absolute_name @context_card.name
    end
  end
end
