# -*- encoding : utf-8 -*-

class AddAssetFileCard < Card::Migration::Core
  def up
    ensure_code_card "Asset file", type_id: Card::CardtypeID
  end
end
