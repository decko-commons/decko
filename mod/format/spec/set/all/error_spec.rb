# -*- encoding : utf-8 -*-

describe Card::Set::All::Error do
  check_views_for_errors format: :base, views: (views(:base) - [:server_error])
  check_views_for_errors format: :json

  describe "unknown view" do
    it "prompts to add" do
      puts render_content("{{+cardipoo|open}}")
      expect(render_content("{{+cardipoo|open}}"))
        .to have_tag("i.material-icons", text: "add_box")

    end
  end
end
