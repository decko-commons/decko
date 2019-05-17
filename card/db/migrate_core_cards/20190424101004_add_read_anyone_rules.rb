# -*- encoding : utf-8 -*-

class AddReadAnyoneRules < Card::Migration::Core
  def up
    ensure_card "*main menu", codename: :main_menu
    cards = %i[title main menu navbox credit credit_image].map { |c| [c, :self] }
    cards << %i[head right]
    cards.each do |codename, set|
      ensure_code_card codename
      ensure_card [codename, set, :read], type_id: Card::PointerID, content: "Anyone"
    end
  end
end
