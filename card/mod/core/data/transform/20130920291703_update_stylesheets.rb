# -*- encoding : utf-8 -*-

class UpdateStylesheets < Cardio::Migration::Core
  def up
    Card["*all+*style+file"]&.delete!
  end
end
