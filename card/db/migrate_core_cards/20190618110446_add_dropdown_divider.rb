# -*- encoding : utf-8 -*-

class AddDropdownDivider < Card::Migration::Core
  def up
    ensure_code_card "*dropdown divider", type_id: Card::HtmlID
    merge_pristine_cards %w[*main_menu *getting_started+link]
  end
end
