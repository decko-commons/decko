def self.included host_class
  host_class.mattr_accessor :file_content_mod_name
  host_class.file_content_mod_name = Card::Set.mod_name(caller)
end

# FIXME: these should abstracted and configured on the types
# (same codes for `rake card:create:codefile`)

# @return [Array<String>, String] the name of file(s) to be loaded
def source_files
  case type_id
  when CoffeeScriptID then "#{codename}.js.coffee"
  when JavaScriptID   then "#{codename}.js"
  when CssID          then "#{codename}.css"
  when ScssID         then "#{codename}.scss"
  end
end

def source_dir
  case type_id
  when CoffeeScriptID, JavaScriptID then "lib/javascript"
  when CssID, ScssID then "lib/stylesheets"
  else
    "lib"
  end
end

def find_file filename
  modname = file_content_mod_name
  modname = $1 if modname =~ /card-mod-(\w*)-\S/
  mod_path = Card::Mod.dirs.path modname
  file_path = File.join(mod_path, source_dir, filename)
  unless File.exist?(file_path)
    Rails.logger.info "couldn't locate file #{filename} at #{file_path}"
    return nil
  end
  file_path
end

def existing_source_paths
  Array.wrap(source_files).map do |filename|
    find_file(filename)
  end.compact
end

def source_changed? since:
  existing_source_paths.any? { |path| ::File.mtime(path) > since }
end

def content
  Array.wrap(source_files).map do |filename|
    if (source_path = find_file filename)
      Rails.logger.info "reading file: #{source_path}"
      File.read source_path
    end
  end.compact.join "\n"
end

format :html do
  view :input do
    "Content is stored in file and can't be edited."
  end

  view :file_size do
    "#{card.name}: #{number_to_human_size card.content.bytesize}"
  end

  def short_content
    fa_icon("exclamation-circle", class: "text-muted pr-2") +
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
