# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::RichHtml::Wrapper do
  context "with full wrapping" do
    let(:ocslot)  { Card["A"].format }

    it "has the appropriate attributes on open" do
      expect_view(:open, card: "A")
        .to have_tag'div.card-slot.open-view.ALL.TYPE-rich_text.SELF-a' do
          with_tag 'div.d0-card-frame.card' do
            with_tag 'div.d0-card-header.card-header' do
              with_tag 'div.d0-card-header-title'
            end
            with_tag 'div.d0-card-body'
          end
        end
    end

    it "has the appropriate attributes on closed" do
      expect_view(:closed, card: "A")
        .to have_tag 'div.card-slot.closed-view.ALL.TYPE-rich_text.SELF-a' do
          with_tag 'div.d0-card-frame.card' do
            with_tag 'div.d0-card-header.card-header' do
              with_tag 'div.d0-card-header-title'
            end
            without_tag 'div.d0-card-body.d0-card-content'
          end
        end
    end
  end
end
