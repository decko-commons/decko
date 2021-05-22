include_set Abstract::CodeFile

def self.included host_class
  Abstract::CodeFile.track_mod_name host_class, caller
end

def source_dir
  "vendor"
end
