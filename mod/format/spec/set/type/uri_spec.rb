# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Uri do
  def card_subject
    Card.new type: "URI",
             name: "A URI card",
             content: "https://decko.org/Home"
  end

  context "with HTML format" do
    specify "input view" do
      expect_view(:input).to have_tag('input[type="text"][class~="d0-card-content"]')
    end

    specify "title_link view" do
      expect_view(:title_link)
        .to have_tag('a[class="external-link"][href="https://decko.org/Home"]',
                     text: "A URI card")
    end

    specify "url_link view" do
      expect_view(:url_link)
        .to have_tag('a[class="external-link"][href="https://decko.org/Home"]',
                     text: "https://decko.org/Home")
    end

    specify "core view with title arg" do
      expect(format_subject.render_core(title: "My Title"))
        .to have_tag('a[class="external-link"][href="https://decko.org/Home"]') do
          with_tag 'span[class="card-title"]', text: "My Title"
        end
    end
  end

  context "with TEXT format" do
    specify "url_link view" do
      expect_view(:url_link, format: :base).to eq "https://decko.org/Home"
    end
  end
end
