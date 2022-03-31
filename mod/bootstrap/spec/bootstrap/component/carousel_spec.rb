# -*- encoding : utf-8 -*-

RSpec.describe Card::Bootstrap::Component::Carousel do
  subject { Card["A"].format(:html) }

  specify "carousel helper" do
    id = "csID"
    carousel = subject.bs_carousel id, 0 do
      item do
        @html.img src: "item1"
      end
      item "item 2"
    end

    expect(carousel).to have_tag "div.carousel.slide#csID", "data-ride" => "carousel" do
      with_tag "ol.carousel-indicators" do
        with_tag "li.active", with: { "data-bs-target" => "##{id}", "data-slide-to" => "0" }
        with_tag "li", with: { "data-bs-target" => "##{id}", "data-slide-to" => "1" }
      end
      with_tag "div.carousel-inner", role: "listbox" do
        with_tag "div.carousel-item.active" do
          with_tag :img, with: { src: "item1" }
        end
        with_tag "div.carousel-item" do
          with_text(/item 2/)
        end
      end
      with_tag "a.carousel-control-prev", href: "##{id}", role: "button",
                                          "data-slide" => "prev" do
        with_tag "span.carousel-control-prev-icon"
        with_tag "span.sr-only", text: "Previous"
      end
      with_tag "a.carousel-control-next", href: "##{id}", role: "button",
                                          "data-slide" => "next" do
        with_tag "span.carousel-control-next-icon"
        with_tag "span.sr-only", text: "Next"
      end
    end
  end

  it "doesn't escape markup" do
    carousel = subject.bs_carousel "csID", 0 do
      item "<strong>item 2</strong>"
    end
    expect(carousel).to have_tag "div.carousel-item" do
      with_tag :strong, text: "item 2"
    end
  end
end
