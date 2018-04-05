# -*- encoding : utf-8 -*-

describe Card::Set::All::Links do
  def link_to *args
    format.link_to(*args)
  end

  def link_to_view *args
    format.link_to_view(*args)
  end

  def link_to_card *args
    format.link_to_card(*args)
  end

  def link_to_related *args
    format.link_to_related(*args)
  end

  def link_to_resource *args
    format.link_to_resource(*args)
  end

  context "when in base format" do
    let :format do
      Card["Home"].format(:base)
    end

    describe "#link_to" do
      it "returns simple link without args" do
        expect(link_to).to eq("/Home")
      end

      it "returns simple link with only path opts" do
        expect(link_to(nil, path: { mark: "A" })).to eq("/A")
      end

      it "returns annotated link if text is given" do
        expect(link_to("Grade", path: { mark: "A" })).to eq("Grade[/A]")
      end
    end

    describe "#link_to_view" do
      it "adds view param to path" do
        expect(link_to_view(:listing)).to eq("/Home?view=listing")
      end

      it "adds handles text and opts" do
        expect(link_to_view(:listing, "house", path: { format: :txt }))
          .to eq("house[/Home.txt?view=listing]")
      end
    end

    describe "#link_to_card" do
      it "creates a link to a different card" do
        expect(link_to_card("Banana")).to eq("/Banana")
      end

      it "creates a link to a different card with a different title" do
        expect(link_to_card("Banana", "Rama")).to eq("Rama[/Banana]")
      end

      it "creates a link to a different card with params" do
        expect(link_to_card("Banana", nil, path: { format: :txt, view: :core }))
          .to eq("/Banana.txt?view=core")
      end
    end

    describe "#link_to_related" do
      it "creates a link to a related view" do
        expect(link_to_related(:discussion))
          .to eq("/Home?related%5Bname%5D=%2Bdiscussion&view=related")
      end
    end

    describe "#link_to_resource" do
      it "doesn't alter absolute urls" do
        expect(link_to_resource("http://www.www.com"))
          .to eq("http://www.www.com")
      end
    end
  end

  context "when in html format" do
    let :format do
      Card["Home"].format(:html)
    end
    describe "#link_to_resource" do
      it "opens external link in new tab" do
        assert_view_select link_to_resource("http://example.com"),
                           'a[class="external-link"][target="_blank"]' \
                           '[href="http://example.com"]'
      end

      it "opens internal link in same tab" do
        assert_view_select link_to_resource("/Home"),
                           'a[target="_blank"]',
                           false
      end
    end

  end
end
