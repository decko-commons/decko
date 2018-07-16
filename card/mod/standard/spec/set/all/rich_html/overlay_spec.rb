# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::Overlay do
  describe "overlay layout", params: { layout: :overlay } do
    # before do
    #   Card::Env.params[:layout] = :overlay
    # end
    # after do
    #   Card::Env.params.delete :layout
    # end

    subject do
      Card["A"].format.show :core, {}
    end

    specify do
      is_expected.to have_tag("div.card-slot.SELF-a._overlay.d0-card-overlay") do
        with_tag "div#main" do
          with_tag "span.card-title", "Z"
        end
      end
    end
  end
end
