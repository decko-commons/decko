# -*- encoding : utf-8 -*-

class AddReadAnyoneRules < Card::Migration::Core
  def up
    cards = [:title, "*main menu", :navbox, :credit, :credit_image].map { |c| [c, :self] }
    cards << [:head, :right]
    cards.each do |codename, set|
      ensure_card [codename, set, :read], type_id: Card::PointerID,
                  content: "Anyone"
    end
  end
end
