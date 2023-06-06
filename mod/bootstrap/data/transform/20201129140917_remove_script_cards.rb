
class RemoveScriptCards < Cardio::Migration::Transform
  def up
    delete_code_card :script_select2
    delete_code_card :script_bootstrap
    delete_code_card :script_jquery_helper
    delete_code_card :script_jquery
  end
end
