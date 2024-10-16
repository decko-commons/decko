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

    attr_accessor :context_card, :keys, :cardmap

    def initialize context_card
      @context_card = context_card
      @keys = ::Set.new
    end

    def cardmap
      @cardmap ||= {}
    end

    def keys
      cardmap.keys
    end

    def [] name
      card(name) || field(name)
    end

    def field name
      cardmap.find { |_k, c| c.name.right_name == name.to_name }
    end

    def card name
      cardmap[name.to_name.key]
    end

    def present?
      cardmap.present?
    end

    def catch_up_to_stage stage_index
      each_card do |subcard|
        subcard.catch_up_to_stage stage_index
      end
    end

    def rename old_name, new_name
      return unless cardmap.keys.include? old_name.to_name.key

      card = cardmap.delete old_name.to_name.key
      cardmap[new_name.to_name.key] = card if card
    end

    # def respond_to_missing? method_name, _include_private=false
    #   map.keys.respond_to? method_name
    # end
    #
    # def method_missing method, *args
    #   return unless respond_to_missing?(method)
    #
    #   map.keys.send method, *args
    # end

    # fetch all cards first to avoid side effects
    # e.g. deleting a user adds follow rules and +*account to subcards
    # for deleting but deleting follow rules can remove +*account from the
    # cache if it belongs to the rule cards
    def cards
      cardmap.values
    end

    def each_card &block
      cards.each(&block)
    end

    alias_method :each, :each_card

    def each_with_key &block
      cardmap.each &block
    end
  end
end
