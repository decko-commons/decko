# -*- encoding : utf-8 -*-

class AddNestListType < Cardio::Migration::Core
  def up
    ensure_code_card "Nest list", type_code: :cardtype
    Card::Cache.reset_all
    ensure_card %i[structure right default], type_code: :nest_list
  end
end
