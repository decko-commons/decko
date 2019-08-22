# -*- encoding : utf-8 -*-

class MoveHelpTextToCode < Card::Migration::Core
  def up
    # avoid that "list" as input option gets the description of the cardtype "list"
    ensure_card [:input, :right, :options_label], "options description"

    remove_setting_help_rules
  end

  def remove_settting_help_rules
    %i[script input read update create delete accountable add_help autoname captcha create
       default structure comment follow_fields].each do |trait|
      delete_card [trait, :right, :help]
    end
  end
end
