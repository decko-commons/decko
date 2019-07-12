# -*- encoding : utf-8 -*-

class AddSharkAndHelpDeskRole < Card::Migration::Core
  def up
    # delete_code_card :eagle
    # update :anyone_signed_in, name: "Eagle", update_referers: true
    ensure_role "Shark", codename: "shark"
    ensure_role "Help Desk", codename: "help_desk"

    ensure_card "*account settings",
                codename: "account_settings", type_id: Card::BasicID

    update_card "Decker Menu", name: "Shark Menu", update_referers: true
    update_card :ace, name: "*ace"
    update_card "*google_analytics_key", name: "*google analytics key"

    remove_deprecated_cards
    delete_right_read_permissions
    delete_self_read_permissions
    remove_redundant_permissions
    add_shark_permissions
    add_help_desk_permissions

    merge_cards %w[role+*type+*structure
                administrator+dashboard administrator+description
                shark+dashboard shark+description
                help_desk+dashboard help_desk+description
                anyone_signed_in+dashboard eagle+description
                *recaptcha_settings+*self+*structure
                *account_settings+*right+*structure
                *getting_started+shark
                right_thin_sidebar_layout left_sidebar_layout
                *getting_started]
  end

  private

  def remove_deprecated_cards
    delete_code_card "Config"
    delete_code_card :foot
    delete_code_card :toolbar_pinned
    delete_card "*edit toolbar pinned"
    delete_card "Administrator Menu"
    delete_card "*ProseMirrorz"
    delete_card "Home+original"
  end

  def delete_right_read_permissions
    %i[machine_output head script style solid_cache].each do |n|
      delete_card [n, :right, :read]
    end
  end

  def delete_self_read_permissions
      %i[account_links signin version title].each do |n|
        delete_card [n, :self, :read]
      end
    end

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
