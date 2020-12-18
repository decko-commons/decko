# -*- encoding : utf-8 -*-

class AddNestListType < Cardio::Migration::Core
  def up
    ensure_code_card "Nest list", type_id: Card::CardtypeID
    Card::Cache.reset_all
    ensure_card [:structure, :right, :default], type_id: ::Card::NestListID
  end
end
