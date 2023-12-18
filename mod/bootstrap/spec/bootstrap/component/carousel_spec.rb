# -*- encoding : utf-8 -*-

RSpec.describe ::Card::Bootstrap::Component::Carousel do
  let(:id) { "csID"}

  subject do
    card = ::Card["A"].format(:html)
    card.bs_carousel id, 0 do
      item do
        @html.img src: "item1"
      end
      item "item 2"
    end
  end

  describe "carousel helper" do
    it "has indicators" do
      expect(subject).to have_tag "div.carousel.slide#csID", "data-bs-ride" => "true" do
        with_tag "div.carousel-indicators" do
          with_tag "button.active", with: { "data-bs-target": "##{id}",
                                            "data-bs-slide-to": "0" }
          with_tag "button", with: { "data-bs-target": "##{id}", "data-bs-slide-to": "1" }
        end
      end
    end

    it "has items" do
      expect(subject).to have_tag "div.carousel.slide#csID" do
        with_tag "div.carousel-inner", role: "listbox" do
          with_tag "div.carousel-item.active" do
            with_tag :img, with: { src: "item1" }
          end
          with_tag("div.carousel-item") { with_text(/item 2/) }
        end
      end
    end

    it "has previous button" do
      expect(subject).to have_tag "div.carousel.slide#csID" do
        with_tag "button.carousel-control-prev",
                 "data-bs-target": "##{id}",
                 type: "button",
                 "data-bs-slide": "prev" do
          with_tag "span.carousel-control-prev-icon"
          with_tag "span.visually-hidden", text: "Previous"
        end
      end
    end

    it "has next button" do
      expect(subject).to have_tag "div.carousel.slide#csID" do
        with_tag "button.carousel-control-next", "data-bs-target": "##{id}", type: "button",
                                                 "data-bs-slide": "next" do
          with_tag "span.carousel-control-next-icon"
          with_tag "span.visually-hidden", text: "Next"
        end
      end
    end
  end

  it "doesn't escape markup" do
    carousel = ::Card["A"].format(:html).bs_carousel "csID", 0 do
      item "<strong>item 2</strong>"
    end
    expect(carousel).to have_tag "div.carousel-item" do
      with_tag :strong, text: "item 2"
    end
  end
end
