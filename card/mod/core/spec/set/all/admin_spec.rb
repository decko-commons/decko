RSpec.describe Card::Set::All::Admin do
  specify "admin_config_by_mods" do
    expect(Card[:all].all_admin_configs_grouped_by(:mod["mod: permissions"])
      .to eq({ "settings" => %w[create read update delete]})
  end

  specify "admin_config_by_config_type" do
    expect(Card[:all].admin_config_by_config_type["settings"].map { |x| x.codename })
      .to include("create")
  end

  specify "admin_config_create_setting" do
    create_config = Card[:all].admin_config_by_config_type["settings"].find { |x| x.codename == "create" }
    expect(create_config.roles).to eq(["Shark"])
  end

  specify "admin_config_by_role" do
    roles = Card[:all].all_admin_configs_grouped_by(:roles)
    expect(roles["Anyone Signed In"].map { |c| c.codename})
      .to contain_exactly("mod", "user", "setting", "json", "number", "plain_text", "toggle", "phrase", "uri",
                          "list", "pointer", "email_template", "file", "image", "link_list",
                          "local_script_folder_group", "local_script_manifest_group", "local_style_folder_group",
                          "nest_list", "remote_manifest_group", "role", "local_style_manifest_group", "bootswatch_skin",
                          "date", "notification_template", "session")
  end
end
