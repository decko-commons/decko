# -*- encoding : utf-8 -*-
require_dependency "card/cache"
require_dependency "card/name"

class Card
  # {Card}'s names can be changed, and therefore _names_ should not be directly mentioned in code, lest a name change break the application.
  #
  # Instead, a {Card} that needs specific code manipulations should be given a {Codename}, which will not change even if the card's name
  # does.
  #
  # An administrator might add to the Company card via the RESTful web API with a url like
  #
  #     /update/CARDNAME?card[codename]=CODENAME
  #
  # ...or via the api like
  #
  #     Card[CARDNAME].update_attributes! codename: CODENAME
  #
  # Generally speaking, _codenames_ are represented by Symbols.
  #
  # The {Codename} class provides a fast cache for this slow-changing data. Every process maintains a complete cache that is not frequently reset
  #
  class Codename
    class << self
      # returns codename for id and id for codename
      # @param key [Integer, Symbol, String, Card::Name]
      # @return [Symbol]
      def [] codename
        case codename
        when Integer
          codehash[codename]
        when Symbol, String
          codehash.key?(codename.to_sym) ? codename.to_sym : nil
        end
      end

      def id codename
        case codename
        when Symbol, String
          codehash[codename.to_sym]
        when Integer
          codehash.key?(codename) ? codename : nil
        end
      end

      def name codename
        name! codename
      rescue Error::CodenameNotFound => _e
        yield if block_given?
      end

      def card codename
        if (card_id = id(codename))
          Card[card_id]
        elsif block_given?
          yield
        end
      end

      def exist? codename
        id(codename).present?
      end

      alias_method :exists?, :exist?

      # a Hash in which Symbol keys have Integer values and vice versa
      # @return [Hash]
      def codehash
        @codehash ||= load_codehash
      end

      # clear cache both locally and in cache
      def reset_cache
        @codehash = nil
        Card.cache.delete "CODEHASH"
      end

      # @param codename [Symbol, String]
      # @return [Integer]
      def id! codename
        id(codename) || unknown_codename!(codename)
      end

      # @param codename [Symbol, String]
      # @return [Card::Name]
      def name! codename
        Card::Name[codename.to_sym]
      end

      private

      # iterate through every card with a codename
      # @yieldparam codename [Symbol]
      # @yieldparam id [Integer]
      def each_codenamed_card
        sql = "select id, codename from cards where codename is not NULL"
        ActiveRecord::Base.connection.select_all(sql).each do |row|
          yield row["codename"].to_sym, row["id"].to_i
        end
      end

      # @todo remove duplicate checks here; should be caught upon creation
      def check_duplicates codehash, codename, card_id
        return unless codehash.key?(codename) || codehash.key?(card_id)
        warn "dup codename: #{codename}, ID:#{card_id} (#{codehash[codename]})"
      end

      # generate Hash for @codehash and put it in the cache
      def load_codehash
        Card.cache.fetch("CODEHASH") do
          generate_codehash
        end
      end

      def generate_codehash
        hash = {}
        each_codenamed_card do |codename, card_id|
          check_duplicates hash, codename, card_id
          hash[codename] = card_id
          hash[card_id] = codename
        end
        hash
      end

      def unknown_codename! mark
        raise Card::Error::CodenameNotFound, I18n.t(:exception_unknown_codename,
                                            scope: "lib.card.codename",
                                            codename: mark)
      end
    end
  end

  # If a card has the codename _example_, then Card::ExampleID should
  # return the id for that card. This method makes that help.
  #
  # @param const [Const]
  # @return [Integer]
  # @raise error if codename is missing
  def self.const_missing const
    return super unless const.to_s =~ /^([A-Z]\S*)ID$/
    code = Regexp.last_match(1).underscore
    code_id = Card::Codename.id!(code)
    const_set const, code_id
  end
end
