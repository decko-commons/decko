# -*- encoding : utf-8 -*-

require "rspec-html-matchers"

RSpec.describe Card::Set::All::Base do
  describe "handles view" do
    describe "name view" do
      it("name") { expect(render_card(:name)).to eq("Tempo Rary") }

      it "pluralizes" do
        name = render_content "{{Joe User|name; variant: plural}}"
        expect(name).to eq("Joe Users")
      end

      it "singularizes" do
        name = render_content "{{Sunglasses|name; variant: singular}}"
        expect(name).to eq("Sunglass")
      end

      it "handles more than one variant" do
        name = render_content "{{Sunglasses|name; variant: singular, upcase}}"
        expect(name).to eq("SUNGLASS")
      end
    end

    it("key") { expect(render_card(:key)).to eq("tempo_rary") }
    it("linkname") { expect(render_card(:linkname)).to eq("Tempo_Rary") }

    it "url" do
      Cardio.with_config deck_origin: "http://eric.skippy.com" do
        expect(render_card(:url)).to eq("http://eric.skippy.com/Tempo_Rary")
      end
    end

    it :raw do
      @a = Card.new content: "{{A}}"
      expect(@a.format._render(:raw)).to eq("{{A}}")
    end

    it "core" do
      expect(render_card(:core, name: "A+B")).to eq("AlphaBeta")
    end

    it "core for new card" do
      expect(Card.new.format._render_core).to eq("")
    end

    specify "url_link" do
      expect_view(:url_link, format: :base).to eq("/A")
    end

    specify "url_link in html format" do
      expect(card_subject.format.render_url_link)
        .to have_tag('a[class="internal-link"][href="/A"]',
                     text: "/A")
    end
  end
end
