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
    carousel = subject.bs_carousel "csID" do
      item do

      end
      item active: true do

      end
    end

    expect(carousel).to have_tag "div.carousel.slide#csID" do
      with_tag "ol.carousel-indicators"
    end
  end
end
