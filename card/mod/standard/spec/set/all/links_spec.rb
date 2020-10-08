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
        expect(link_to_view(:bar)).to eq("/Home?view=bar")
      end

      it "adds handles text and opts" do
        expect(link_to_view(:box, "house", path: { format: :txt }))
          .to eq("house[/Home.txt?view=box]")
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

    describe "#link_to_resource" do
      it "doesn't alter absolute urls" do
        expect(link_to_resource("http://www.www.com"))
          .to eq("http://www.www.com")
      end

      it "doesn't alter absolute paths" do
        expect(link_to_resource("/woogles")).to eq("/woogles")
      end
    end
  end

  context "when in html format" do
    let :format do
      Card["Home"].format(:html)
    end

    describe "#link_to" do
      it "returns a simple anchor tag if only given text" do
        expect(link_to("Germany")).to eq(%(<a>Germany</a>))
      end

      it "returns tag link with only href attribute for empty path hash" do
        expect(link_to(nil, path: {})).to eq(%(<a href="/Home">/Home</a>))
      end

      it "handles string paths" do
        expect(link_to(nil, path: "http://google.com"))
          .to eq(%(<a href="http://google.com">http://google.com</a>))
      end

      it "handles :href in addition to :path" do
        expect(link_to(nil, href: "http://google.com"))
          .to eq(%(<a href="http://google.com">http://google.com</a>))
      end
    end

    describe "#link_to_card" do
      it "handles known cards" do
        expect(link_to_card("Menu"))
          .to eq(%(<a class="known-card" href="/Menu">Menu</a>))
      end
    end

    describe "#link_to_view" do
      it "adds remote handling and nofollow" do
        assert_view_select(link_to_view("bar", "list me"),
                           'a[href="/Home?view=bar"]' \
                           "[data-remote=true]" \
                           "[rel=nofollow]") { "list me" }
      end
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
