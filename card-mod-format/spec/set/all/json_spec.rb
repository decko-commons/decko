# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::Json do
  include_context "json context"
  specify "nucleus view" do
    expect_view(:nucleus, format: :json)
      .to eq nucleus_values
  end

  specify "atom view" do
    expect_view(:atom, format: :json)
      .to eq atom_values
  end

  describe "molecule view" do
    def basic_nucleus
      Card[:basic].format(:json).render :nucleus
    end

    context "with internal link" do
      it "has link url" do
        expect_view(:molecule, format: :json)
          .to eq atom_values.merge items: [],
                                   links: [json_url("Z")],
                                   ancestors: [],
                                   type: basic_nucleus,
                                   html_url: "http://json.com/A"
      end
    end

    context "with external link" do
      def card_subject
        @card ||= create "external link",
                         content: "[[http://xkcd.com|link text]]" \
                                  "[[/Z]]"
      end

      it "has link urls" do
        expect_view(:molecule, format: :json)
          .to eq atom_values.merge items: [],
                                   links: ["http://xkcd.com", url("Z")],
                                   ancestors: [],
                                   type: basic_nucleus,
                                   html_url: "http://json.com/external_link"
      end
    end

    context "with nests" do
      def card_subject
        Card["B"]
      end

      it "has nests" do
        expect_view(:molecule, format: :json)
          .to eq atom_values.merge items: [atom_values(Card["Z"])],
                                   links: [],
                                   ancestors: [],
                                   type: basic_nucleus,
                                   html_url: "http://json.com/B"
      end
    end
  end

  context "status view" do
    it "handles real and virtual cards" do
      jf = Card::Format::JsonFormat
      real_json = jf.new(Card["T"]).show :status, {}
      expect(JSON[real_json]).to eq(
        "key" => "t", "status" => "real", "id" => Card["T"].id, "url_key" => "T"
      )
      virtual_json = jf.new(Card.fetch("T+*self")).show :status, {}
      expect(JSON[virtual_json]).to eq(
        "key" => "t+*self", "status" => "virtual", "url_key" => "T+*self"
      )
    end

    it "treats both unknown and unreadable cards as unknown" do
      Card::Auth.as Card::AnonymousID do
        jf = Card::Format::JsonFormat

        unknown = Card.new name: "sump"
        unreadable = Card.new name: "kumq", type: "Fruit"
        unknown_json = jf.new(unknown).show :status, {}
        expect(JSON[unknown_json]).to eq(
          "key" => "sump", "status" => "unknown", "url_key" => "sump"
        )
        unreadable_json = jf.new(unreadable).show :status, {}
        expect(JSON[unreadable_json]).to eq(
          "key" => "kumq", "status" => "unknown", "url_key" => "kumq"
        )
      end
    end
  end
end
