# -*- encoding : utf-8 -*-

class AddDeveloperCards < Cardio::Migration::Transform
  def up
    Card.ensure name: "*debug",
                codename: "debug"
    Card.ensure name: "*debug+*right+*read",
                type_id: Card::PointerID,
                content: "[[Administrator]]"
  end
end
