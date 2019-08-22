# -*- encoding : utf-8 -*-

class MoveHelpTextToCode < Card::Migration::Core
  def up
    update_card "*sidebar", codename: "sidebar"
    Card::Cache.reset_all

    # avoid that "list" as input option gets the description of the cardtype "list"
    ensure_card [:input, :right, :options_label], "options description"


    remove_setting_help_rules
    remove_self_help_rules :favicon, :tiny_mce, :favicon, :datepicker, "*debugger",
                           :prose_mirror, :sidebar

  end

  def remove_setting_help_rules
    %i[script input read update create delete accountable add_help autoname captcha create
       default structure comment follow_fields options thanks layout options_label help
       head table_of_contents style on_create on_update on_delete].each do |trait|
      delete_card [trait, :right, :help]
    end
  end

  def remove_self_help_rules *anchors
    anchors.each do |a|
      delete_card [a, :self, :help]
    end
  end
end
