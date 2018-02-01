# -*- encoding : utf-8 -*-

describe Card::Set::All::RichHtml::Editing do
  let(:mycard) { Card["A"] }
  let(:myformat) { mycard.format }

  def assert_active_toolbar_pill view, content, related_view=false
    view_selector = related_view ? "related" : view
    assert_view_select myformat.render!(view),
                       "div[class~='card-slot #{view_selector}-view']" do
      assert_select 'nav[class="slotter toolbar navbar navbar-inverse"]' do
        assert_select 'ul[class="nav navbar-nav nav-pills"]' do
          assert_select 'li[class~="active"] > a', content
        end
      end
    end
  end

  describe "edit_nests view" do
    it "shows editors for both absolute and relative nests" do
      mycard.content = "{{absolute}} AND {{+relative}}"
      view = myformat.render :edit_nests
      expect(view).to have_tag "div.SELF-a" do
        with_tag "div.card-editor", with: { card_name: "absolute" }
        with_tag "div.card-editor", with: { card_name: "A+relative" }
      end
    end
  end

  # outdated
  # TODO: write tests for new toolbar
  # describe "edit view" do
  #   it "has toolbar with active 'content' pill" do
  #     assert_active_toolbar_pill :edit, 'content'
  #   end
  # end
  #
  # describe 'edit_type view' do
  #   it "has toolbar with active 'type' pill" do
  #     assert_active_toolbar_pill :edit_type, 'type'
  #   end
  # end
  #
  # describe 'edit_name view' do
  #   it "has toolbar with active 'name' pill" do
  #     assert_active_toolbar_pill :edit_name, 'name'
  #   end
  # end
  #
  # describe 'edit_structure view' do
  #   before do
  #     @mycard = Card["Iliad"].format
  #   end
  #   it "has toolbar with active 'rules' pill" do
  #     Card::Auth.as_bot do
  #       assert_active_toolbar_pill :edit_structure, 'rules', true
  #     end
  #   end
  # end
  #
  # describe 'edit_nests view' do
  #   before do
  #     Card::Auth.as_bot do
  #       Card.create! name: 'Iliad+author', content: 'Homer'
  #     end
  #     @mycard = Card["Iliad"].format
  #   end
  #   it "has toolbar with active 'nests' pill" do
  #     assert_active_toolbar_pill :edit_nests, 'nests'
  #   end
  # end
end
