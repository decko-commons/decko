# -*- encoding : utf-8 -*-
<<-HTML

HTML<div id="carouselExampleIndicators" class="carousel slide" data-ride="carousel">
<ol class="carousel-indicators">
<li data-target="#carouselExampleIndicators" data-slide-to="0" class="active"></li>
    <li data-target="#carouselExampleIndicators" data-slide-to="1"></li>
<li data-target="#carouselExampleIndicators" data-slide-to="2"></li>
  </ol>
<div class="carousel-inner" role="listbox">
<div class="carousel-item active">
<img class="d-block img-fluid" src="..." alt="First slide">
</div>
    <div class="carousel-item">
      <img class="d-block img-fluid" src="..." alt="Second slide">
    </div>
<div class="carousel-item">
<img class="d-block img-fluid" src="..." alt="Third slide">
</div>
  </div>
<a class="carousel-control-prev" href="#carouselExampleIndicators" role="button" data-slide="prev">
<span class="carousel-control-prev-icon" aria-hidden="true"></span>
    <span class="sr-only">Previous</span>
</a>
  <a class="carousel-control-next" href="#carouselExampleIndicators" role="button" data-slide="next">
    <span class="carousel-control-next-icon" aria-hidden="true"></span>
<span class="sr-only">Next</span>
  </a>
</div>
HTML

describe Bootstrap::Component::Carousel do
  subject { Card["A"].format(:html) }
  specify "carousel helper" do
    id = "csID"
    carousel = subject.bs_carousel id, 2, active: 1 do
      inner do
        item do
          tag :img, src: "item1"
        end
        item "item 2"
      end
    end

    expect(carousel).to have_tag "div.carousel.slide#csID" do
      with_tag "ol.carousel-indicators" do
        with_tag "li", with: { "data-target" => "##{id}", "data-slide-to" => "0" }
        with_tag "li.active", with: { "data-target" => "##{id}", "data-slide-to" => "1" }
      end
      with_tag "div.carousel-inner" do
        with_tag "div.carousel-item" do
          with_tag :img, with: { src: "item1" }
        end
        with_tag "div.carousel-item.active" do
          with_text /item 2/
        end
      end
    end
  end
end
