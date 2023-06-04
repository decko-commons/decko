# -*- encoding : utf-8 -*-

class UpdateStylesheets < Cardio::Migration::TransformMigration
  def up
    Card["*all+*style+file"]&.delete!
  end
end
