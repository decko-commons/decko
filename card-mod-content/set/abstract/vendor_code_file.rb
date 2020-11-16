include_set Abstract::CodeFile

def self.included host_class
  host_class.mattr_accessor :file_content_mod_name
  host_class.file_content_mod_name = Card::Set.mod_name(caller)
end

def source_dir
  "vendor"
end
