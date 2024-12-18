include_set Abstract::Sources
include_set Abstract::CodeContent

class << self
  def included host_class
    track_mod_name host_class, caller
  end

  def track_mod_name host_class, caller
    host_class.mattr_accessor :file_content_mod_name
    host_class.file_content_mod_name = Card::Set.mod_name(caller)
  end
end

def source_paths
  # OVERRIDE to use paths for content
end

def content
  Array.wrap(source_paths).map do |path|
    if (source_path = find_file path)
      Rails.logger.debug "reading file: #{source_path}"
      ::File.read source_path
    end
  end.compact.join "\n"
end

format :html do
  view :file_size do
    "#{card.name}: #{number_to_human_size card.content.bytesize}"
  end
end
