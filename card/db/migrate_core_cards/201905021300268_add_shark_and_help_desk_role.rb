# -*- encoding : utf-8 -*-

class AddSharkAndHelpDeskRole < Card::Migration::Core
  def up
    ensure_role "Eagle", codename: "eagle"
    ensure_role "Shark", codename: "shark"
    ensure_role "Help Desk", codename: "help_desk"
    ensure_role "*account settings", codename: "account_settings"
    delete_code_card "Config"
    delete_code_card :foot
    delete_code_card :toolbar_pinned
    delete_card "*edit toolbar pinned"
    delete_card "Administrator Menu"
    delete_card "*ProseMirrorz"
    update_card "Decker Menu", name: "Shark Menu", update_referers: true
    update_card :ace, name: "*ace"
    update_card "*google_analytics_key", name: "*google analytics key"
    ensure_card "*machine output+*right+*read", "_left"

    remove_redundant_permissions
    add_shark_permissions
    add_help_desk_permissions

    merge_cards %w[role+*type+*structure
                administrator+dashboard administrator+description
                shark+dashboard shark+description
                help_desk+dashboard help_desk+description
                eagle+dashboard eagle+description
                *recaptcha_settings+*self+*structure
                *account_settings+*right+*structure
                home+original+shark
                right_thin_sidebar_layout left_sidebar_layout]
  end

  private

  def remove_redundant_permissions
    ["*account+*right+*create",
     "*cached count+*right+*create",
     "*cached content+*right+*create",
     "Config+*self+*delete",
     "Setting+*self+*delete"].each do |name|
      delete_card name
    end

    ["*cached count+*right",
     "*cached content+*right",
     "*google_analytics_key+*self",
     "*admin info+*self",
     "*admin settings+*self",
     "*google_analytics_key+*self",
     "*recaptcha settings+*self",
     "Cardtype+description+*type plus right"].each do |set|
      delete_card [set, :delete]
      delete_card [set, :update]
    end
    delete_card ["Cardtype+description+*type plus right", :create]
  end

  def add_shark_permissions
    %w[Cardtype CoffeeScript CSS	HTML JavaScript	Layout SCSS	Skin].each do |name|
      ensure_cud_permissions name, :type, "Shark"
    end
    ensure_cud_permissions :rstar, nil,"Shark"
  end

  def add_help_desk_permissions
    %w[*account *email *password *salt *status *token].each do |name|
      ensure_card [name, :right, :read], "Help Desk"
    end

    ["*account", "*email", "*password", "*help", "*add help", "*status", "*token"].each do |name|
      ensure_cud_permissions name, :right, "Help Desk"
    end
  end

  def ensure_cud_permissions name, set, content, actions: %i[create update delete]
    actions.each do |action|
      ensure_card [name, set, action].compact, content
    end
  end
end
