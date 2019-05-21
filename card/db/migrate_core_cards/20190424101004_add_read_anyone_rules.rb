# -*- encoding : utf-8 -*-

class AddReadAnyoneRules < Card::Migration::Core
  def up
    ensure_card "*main menu", codename: :main_menu
    ensure_card "*credit", codename: :credit
    cards = %i[title main_menu navbox credit credit_image].map { |c| [c, :self] }
    cards << %i[head right]
    cards.each do |codename, set|
      ensure_card [codename, set, :read], type_id: Card::PointerID, content: "Anyone"
    end
  end
end
