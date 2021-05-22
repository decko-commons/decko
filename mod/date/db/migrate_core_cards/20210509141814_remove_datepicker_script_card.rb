# -*- encoding : utf-8 -*-

class RemoveDatepickerScriptCard < Cardio::Migration::Core
  def up
    delete_code_card :script_datepicker
  end
end
