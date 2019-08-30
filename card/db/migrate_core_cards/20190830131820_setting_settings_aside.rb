# -*- encoding : utf-8 -*-

class SettingSettingsAside < Card::Migration::Core
  def up
    ensure_card %i[account right create], "Administrator"
    ensure_card %i[signup account type_plus_right create], "_left"
    ensure_card %i[user account type_plus_right create], "_left"

    %i[email password status token salt].each do |field|
      # now handled by inheritance
      delete_card [field, :right, :create]
    end

    %i[accountable comment].each do |settingcode|
      next unless (setting = Card[settingcode])
      setting.codename = ""
      setting.delete!
    end
  end
end
