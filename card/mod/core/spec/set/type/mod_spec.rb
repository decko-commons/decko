RSpec.describe Card::Set::Type::Mod do
  check_views_for_errors

  specify "cardtypes" do
    expect(Card[:mod_format].cardtypes)
      .to eq [["Text", %i[basic plain_text html phrase]],
              ["Scripting", [:json]], ["Data", %i[number toggle uri]]]
  end

  specify "admin_config_objects" do
    config_objects = Card[:mod_core].admin_config_objects
    expect(config_objects.size).to eq 7

    expect(config_objects[0].category).to eq "cardtypes"
    expect(config_objects[0].subcategory).to eq "admin"
    expect(config_objects[0].title).to eq "Admin"
    expect(config_objects[0].codename).to eq "mod"
  end

  describe "core view" do
    it "renders Cardtypes and Tasks section for core mod" do
      view = render_card :core, :mod_core
      expect(view).to have_tag :h3, "Cardtypes"
      %w[Mod User Setting Cardtype].each do |cardtype_name|
        expect(view).to have_tag :span, class: "card-title", content: cardtype_name
      end
      expect(view).to have_tag :h3, "Tasks"
    end
  end
end
