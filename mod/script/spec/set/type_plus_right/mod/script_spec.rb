# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Mod::Script do
  describe "view: javascript_include_tag" do
    subject do
      Card[:mod_script, :script].format(:html).render(:javascript_include_tag)
    end
    it "contains remote sources" do
      subject.should include "<script src=\"https://code.jquery.com/jquery-3.6.0.min.js\" crossorigin=\"anonymous\"></script>"
      subject.should include "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/jquery-ujs/1.2.0/rails.min.js\" crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\"></script>"
    end

    it "contains local file" do
      subject.should match %r{<script src="/files/~\d+/\d+.js"></script>}
    end
  end
end
