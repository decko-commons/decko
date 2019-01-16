# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::Overlay do
  describe "overlay layout" do
    subject(:core_view) do
      Card["A"].format.show :core, { wrap: :overlay }
    end

    specify do
      expect(core_view)
        .to have_tag("div.card-slot.SELF-a._overlay.d0-card-overlay") do
          with_tag "div#main" do
            with_tag "span.card-title", "Z"
          end
      end
    end
  end
end
