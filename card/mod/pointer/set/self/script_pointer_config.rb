include_set Abstract::CodeFile

FILE_NAMES = %w[pointer_config pointer_list_editor]

def source_files
  coffee_files FILE_NAMES
end

Self::ScriptEditors.add_item :script_pointer_config
