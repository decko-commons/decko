event :create_alias_upon_rename, :finalize,
      on: :update, changed: :name, trigger: :required do
  add_subcard name_before_act, type_code: :alias, content: name
end

def alias?
  false
end
