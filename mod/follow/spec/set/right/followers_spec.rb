# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Followers do
  describe "#content" do
    it "returns a pointer list of followers" do
      card = Card.fetch "All Eyes on me"
      expect(card.followers_card.item_names.sort)
        .to eq ["Big Brother", "John", "Sara"]
    end
  end

  describe "view :core" do
    it "contains follower" do
      card = Card.fetch "All Eyes on me"
      view = card.followers_card.format.render_core
      expect(view).to include("Sara")
    end
  end

  describe "view :raw" do
    it "renders a pointer list of followers" do
      card = Card.fetch "All Eyes on me"
      view = card.followers_card.format.render_raw
      expect(view.split("\n").sort).to eq ["Big Brother", "John", "Sara"]
    end
  end

  describe "item_names" do
    def followers_of cardish
      card = cardish.is_a?(Card) ? cardish : Card[cardish]
      card.followers_card.item_names.sort
    end

    it "is an array of followers" do
      expect(followers_of("All Eyes On Me")).to eq ["Big Brother", "John", "Sara"]
    end

    it "recognizes card name changes" do
      card = Card["Look At Me"]
      card.update! name: "Look away"
      expect(followers_of(card)).to eq ["Big Brother"]
    end

    it "recognizes +*following changes" do
      Card::Auth.as_bot { Card["Joe User"].follow "Look At Me" }
      expect(followers_of("Look At Me")).to include "Joe User"
    end

    context "when following a card" do
      it "contains follower" do
        expect(followers_of("All Eyes On Me")).to include("Big Brother")
      end
    end

    context "when following a *self set" do
      it "contains follower" do
        expect(followers_of("Look At Me")).to include("Big Brother")
      end
    end

    context "when following a *type set" do
      it "contains follower" do
        card = Card.create! name: "telescope", type: "Optic"
        expect(followers_of(card)).to include("Big Brother")
      end
    end

    context "when following a *right set" do
      it "contains follower" do
        card = Card.create! name: "telescope+lens"
        expect(followers_of(card)).to include("Big Brother")
      end
    end

    context "when following a *type plus right set" do
      it "contains follower" do
        expect(followers_of("Sunglasses+tint")).to include("Big Brother")
      end
    end

    context "when following content I created" do
      it "contains creator" do
        Card::Auth.signin "Big Brother"
        card = Card.create! name: "created by Follower"
        expect(followers_of(card)).to include("Big Brother")
      end
    end

    context "when following content I edited" do
      it "contains editor" do
        Card::Auth.as_bot do
          Card["Sara"].follow "*all", "*edited"
        end

        card = Card.create! name: "edited by Sara"
        Card::Auth.signin "Sara"
        card.update! content: "some content"
        expect(followers_of(card)).to include("Sara")
      end
    end

    context "when called on a set card" do
      it "contains followers of that set" do
        expect(followers_of("lens+*right")).to include("Big Brother")
      end
    end

    context "when called on a type card" do
      it "contains followers of that type" do
        expect(followers_of("Optic")).to include("Optic fan")
      end
    end
  end
end
