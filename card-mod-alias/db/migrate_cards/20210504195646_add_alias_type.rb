# -*- encoding : utf-8 -*-

class AddAliasType < Cardio::Migration
  def up
    ensure_code_card "Alias", type_code: :cardtype
  end
end
