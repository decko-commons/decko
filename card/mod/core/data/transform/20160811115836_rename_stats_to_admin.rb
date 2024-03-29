# -*- encoding : utf-8 -*-

class RenameStatsToAdmin < Cardio::Migration::Transform
  def up
    return if Card::Codename.exist?(:admin) || !Card::Codename.exist?(:stats)

    Card[:stats].update! name: "*admin", codename: "admin"
  end
end
