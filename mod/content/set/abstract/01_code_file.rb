include_set Abstract::Sources

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
  view :input do
    # Localize
    "Content is stored in file and can't be edited."
  end

  view :file_size do
    "#{card.name}: #{number_to_human_size card.content.bytesize}"
  end

  view :bar_middle do
    short_content
  end

  def short_content
    fa_icon("exclamation-circle", class: "text-muted pe-2") +
      wrap_with(:span, "file", class: "text-muted")
  end

  def standard_submit_button
    multi_card_editor? ? super : ""
  end
end

def coffee_files files
  files.map { |f| "script_#{f}.js.coffee" }
end

def scss_files files
  files.map { |f| "style_#{f}.scss" }
end
