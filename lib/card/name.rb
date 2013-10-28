# -*- encoding : utf-8 -*-
require 'smart_name'

class Card
  class Name < SmartName
    Card::Name.params  = Wagn::Env # yuck!
    Card::Name.session = proc { Account.current.name }
    Card::Name.banned_array = ['/']

    def star?
      simple? and '*' == s[0,1]
    end

    def rstar?
      right and '*' == right[0,1]
    end

    def trait_name? *traitlist
      junction? && begin
        right_key = right_name.key
        !!traitlist.find do |codename|
          card_id = Card::Codename[ codename ] and card = Card.fetch( card_id, :skip_modules=>true, :skip_virtual=>true ) and
            card.key == right_key
        end
      end
    end

    def trait_name tag_code
      card_id = Card::Codename[ tag_code ] and card = Card.fetch( card_id, :skip_modules=>true, :skip_virtual=>true ) and
        [ self, card.cardname ].to_name
    end

    def trait tag_code
      trait_name( tag_code ).s
    end
  end
end
