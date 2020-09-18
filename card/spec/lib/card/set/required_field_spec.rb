# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::RequiredField, as_bot: true do
  describe "parent" do
    it "can't be save without required field" do
      card = Card.new name: "reader"
      card.set_with { require_field :read }

      expect { card.save! }.to raise_error, /Read required/
    end

    it "can be saved with required field" do
      card = Card.new name: "reader", "+*read" => "me"
      card.set_with { require_field :read }

      # ARDEP: exception RecordInvalid (apparently can't depend on it defined?)
      expect { card.save! }.not_to raise_error #ActiveRecord::RecordInvalid
    end
  end

  describe "required field" do
    let(:card_with_required_field) do
      card = Card.create name: "reader", "+*read" => "me"
      card.set_with { require_field :read }
      card
    end

    let(:field) do
      card = Card["reader", :read]
      card.singleton_class.send :include, Card::Set::TypePlusRight::DynamicSet::Read
      card
    end

    # ARDEP: exception RecordInvalid
    it "can't be deleted" do
      card_with_required_field
      expect { field.delete! }
        .to raise_error ActiveRecord::RecordInvalid, /required field/
    end

    # it "can't be deleted as simple card" do
    #   card_with_required_field
    #   expect { Card[:read].delete! }
    #     .to raise_error ActiveRecord::RecordInvalid, /required field of reader/
    # end

    it "can't change field name" do
      card_with_required_field
      expect { field.update! name: "reader+something else" }
        .to raise_error ActiveRecord::RecordInvalid, /can't be renamed; required field/
    end

    it "can't change parent name" do
      card_with_required_field
      expect { field.update! name: "writer+something" }
        .to raise_error ActiveRecord::RecordInvalid, /can't be renamed; required field/
    end

    it "can't change name to simple name" do
      card_with_required_field
      expect { field.update! name: "something else" }
        .to raise_error ActiveRecord::RecordInvalid, /can't be renamed; required field/
    end

    it "can be deleted with parent" do
      expect { card_with_required_field.delete! }
        .not_to raise_error ActiveRecord::RecordInvalid
    end
  end
end
