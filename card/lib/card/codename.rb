# -*- encoding : utf-8 -*-

class Card
    # @return [Symbol]
  def codename
    super&.to_sym
  end

  # @return [True/False]
  def codename?
    codename.present?
  end

  # {Card}'s names can be changed, and therefore _names_ should not be directly mentioned
  # in code, lest a name change break the application.
  #
  # Instead, a {Card} that needs specific code manipulations should be given a {Codename},
  # which will not change even if the card's name does.
  #
  # An administrator might add to the Company card via the RESTful web API with a url like
  #
  #     /update/CARDNAME?card[codename]=CODENAME
  #
  # ...or via the api like
  #
  #     Card[CARDNAME].update! codename: CODENAME
  #
  # Generally speaking, _codenames_ are represented by Symbols.
  #
  # The {Codename} class provides a fast cache for this slow-changing data.
  # Every process maintains a complete cache that is not frequently reset
  class Codename
    class << self
      # returns codename for id and id for codename
      # @param codename [Integer, Symbol, String, Card::Name]
      # @return [Symbol]
      def [] codename
        case codename
        when Integer
          codehash[:i2c][codename]
        when Symbol, String
          codehash[:c2i].key?(codename.to_sym) ? codename.to_sym : nil
        end
      end

      # @param codename [Symbol, String]
      # @return [Integer]
      def id codename
        case codename
        when Symbol, String
          codehash[:c2i][codename.to_sym]
        when Integer
          codehash[:i2c].key?(codename) ? codename : nil
        end
      end

      # @param codename [Symbol, String]
      # @return [Card::Name]
      def name codename
        (card_id = id codename) && Lexicon.name(card_id)
      end

      # @param codename [Symbol, String]
      # @return [Card]
      def card codename
        if (card_id = id(codename))
          Card[card_id]
        elsif block_given?
          yield
        end
      end

      # @param codename [Symbol, String]
      # @return [True/False]
      def exist? codename
        id(codename).present?
      end
      alias_method :exists?, :exist?

      # clear codename cache both in local variable and in temporary and shared caches
      def reset_cache
        @codehash = nil
        ::Card.cache.delete "CODENAMES"
      end

      # @param codename [Symbol, String]
      # @return [Integer]
      def id! codename
        id(codename) || unknown_codename!(codename)
      end

      # @param codename [Symbol, String]
      # @return [Card::Name]
      def name! codename
        (card_id = id! codename) && Lexicon.name(card_id)
      end

      # @return [Array<Integer>] list of ids of cards with codenames
      def ids
        codehash[:i2c].keys
      end

      # Creates ruby constants for codenames. Eg, if a card has the codename _gibbon_,
      # then Card::GibbonID will contain the id for that card.
      def generate_id_constants
        codehash[:c2i].each do |codename, id|
          Card.const_get_or_set("#{codename.to_s.camelize}ID") { id }
        end
      end

      # Update a codenamed card's codename
      def recode oldcode, newcode
        return unless id(oldcode) && !id(newcode)

        Rails.logger.info "recode #{oldcode}, #{newcode}"
        Card.where(codename: oldcode).take.update_column :codename, newcode
        reset_cache
      end

      # Queries the database and generates a "codehash" (see #codehash).
      #
      # It _also_ seeds the Card and Lexicon caches with codename details
      #
      # @return [Hash] (the codehash)
      def process_codenames
        codenamed_cards.each_with_object(c2i: {}, i2c: {}) do |card, hash|
          hash[:c2i][card.codename] = card.id
          hash[:i2c][card.id] = card.codename
          seed_caches card
        end
      end

      # A hash of two hashes:
      # - the c2i hash has codenames (symbols) as keys and ids (integers) as values
      # - the i2c hash has the opposite.
      # @return [Hash] (the codehash)
      def codehash
        @codehash ||= load_codehash
      end

      private

      def codenamed_cards
        Card.where "codename is not NULL"
      end

      # generate Hash for @codehash and put it in the cache
      def load_codehash
        Card.cache.fetch("CODENAMES") { process_codenames }
      end

      def seed_caches card
        return if card.left_id

        Card::Lexicon.write card.id, card.name, card.lex
        # Card.cache.write card.key, card
      end

      def unknown_codename! mark
        raise Card::Error::CodenameNotFound,
              ::I18n.t(:lib_exception_unknown_codename, codename: mark)
      end
    end

    generate_id_constants
  end
end
