# -*- encoding : utf-8 -*-

class UpdateStylesheets < Cardio::Migration::Transform
  def up
    Card["*all+*style+file"]&.delete!
  end
end
