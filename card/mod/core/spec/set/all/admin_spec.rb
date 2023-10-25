RSpec.describe Card::Set::All::Admin do
  describe "all_admin_configs_of_category" do
    it "finds settings" do
      expect(Card[:all].all_admin_configs_of_category("settings").map(&:codename))
        .to include("create")
    end

    it "create setting has the correct role" do
      create_config = Card[:all].all_admin_configs_of_category("settings").find { |x| x.codename == "create" }
      expect(create_config.roles).to eq([:shark])
    end

    it "finds views" do
      views = Card[:all].all_admin_configs_of_category("views").map(&:codename)
      expect(views).to include("name", "link", "content")
    end
  end

  specify "admin_config_by_role" do
    roles = Card[:all].all_admin_configs_grouped_by(:roles)
    expect(roles[:anyone_signed_in].map(&:codename))
      .to contain_exactly("mod", "user", "setting", "json", "number", "plain_text",
                          "toggle", "phrase", "uri",
                          "list", "pointer", "email_template", "file", "image",
                          "link_list",
                          "local_script_folder_group", "local_script_manifest_group",
                          "local_style_folder_group",
                          "nest_list", "remote_manifest_group", "role",
                          "local_style_manifest_group", "bootswatch_skin",
                          "date", "notification_template", "session", "basic",
                          "search_type", "signup")
  end
end
