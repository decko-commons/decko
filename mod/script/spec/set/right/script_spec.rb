# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Script do
  check_html_views_for_errors

  xit "updates if source file has changed" do
    # TODO
  end

  describe "view: javascript_include_tag" do
    subject do
      Card[:mod_script, :script].format(:html).render(:javascript_include_tag)
    end
    it "contains remote sources" do
      subject.should include "<script src=\"https://code.jquery.com/jquery-3.6.0.min.js\" crossorigin=\"anonymous\"></script>"
      subject.should include "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/jquery-ujs/1.2.0/rails.min.js\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"></script>"
    end
  end
end

