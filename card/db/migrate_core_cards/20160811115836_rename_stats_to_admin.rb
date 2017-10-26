# -*- encoding : utf-8 -*-

class RenameStatsToAdmin < Card::Migration::Core
  def up
    return if Card::Codename.exist?(:admin) || !Card::Codename.exist?(:stats)
    Card[:stats].update_attributes! name: "*admin", codename: "admin"
  end
end
