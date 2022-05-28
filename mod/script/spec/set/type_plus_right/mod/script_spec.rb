# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::TypePlusRight::Mod::Script do
  describe "view: javascript_include_tag" do
    subject(:script_card) do
      Card[:mod_format, :script].format(:html).render(:javascript_include_tag)
    end

    it "contains remote sources" do
      script_card
        .should include "<script src=\"https://code.jquery.com/jquery-3.6.0.min.js\" "\
                        "crossorigin=\"anonymous\"></script>"
      script_card
        .should include "<script src=\"https://cdnjs.cloudflare.com/ajax/libs/"\
                        "jquery-ujs/1.2.3/rails.min.js\" "\
                        "crossorigin=\"anonymous\" referrerpolicy=\"no-referrer\">"\
                        "</script>"
    end

    it "contains local file" do
      script_card
        .should match %r{<script src="/files/(:[\w_]+|~[\d]+)/[\d\w]+.js"></script>}
    end
  end
end
