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
      item  do

      end
      item active: true do

      end
    end

    expect(carousel).to have_tag "div.carousel.slide#csID" do
      with_tag "ol.carousel-indicators" do
        with_tag
      end
    end
  end
  describe "input" do
    it "has form-group css class" do
      assert_view_select render_editor("Phrase"),
                         'input[type="text"][class~="form-control"]'
    end
  end

  describe "textarea" do
    it "has form-group css class" do
      assert_view_select render_editor("Plain Text"),
                         'textarea[class~="form-control"]'
    end
  end

  describe "form" do


    it "creates form" do
      form =
        subject.bs_form do
          group do
            input "email", "Email Address", id: "theemail"
            input "password", "Password", id: "thepassword"
          end
        end
      expect(form).to have_tag :form do
        with_tag "div.form-group" do
          with_tag :label, with: { for: "theemail" },
                           text: "\nEmail Address"
          with_tag "input.form-control", with: { type: "email", id: "theemail" }
        end
      end
    end
  end

  describe "horizontal form" do
    subject { Card["A"].format(:html) }

    let(:form) do
      subject.bs_horizontal_form 2, 10 do
        group do
          input "email", "Email Address", id: "theemail"
          input "password", "Password", id: "thepassword"
        end
        group do
          checkbox "test", "checkbox label", id: "thecheckbox"
        end
      end
    end
    let(:bsform) do
      subject.bs do
        horizontal_form 2, 10 do
          group do
            input "email", "Email Address", id: "theemail"
            input "password", "Password", id: "thepassword"
          end
          group do
            checkbox "test", "checkbox label", id: "thecheckbox"
          end
        end
      end
    end

    it "creates form" do
      expect(bsform).to have_tag 'form.form-horizontal' do
        with_tag 'div.form-group' do
          with_tag 'label[for="theemail"]', text: /Email Address/
          with_tag 'div.col-sm-10' do
            with_tag 'input.form-control#theemail[type="email"]'
          end
        end
      end
    end
  end
end
