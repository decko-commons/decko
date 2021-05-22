# -*- encoding : utf-8 -*-

require_relative "lib/skin"

class AddStylesheetsCard < Cardio::Migration::Core
  def up
    ensure_card "*stylesheets", codename: "stylesheets"
  end
end
