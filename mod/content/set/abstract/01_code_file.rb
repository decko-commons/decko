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

def mod_path
  modname = file_content_mod_name
  if (match = modname.match(/^card-mod-(\w*)/))
    modname = match[1]
  end
  Cardio::Mod.dirs.path modname
end

def source_paths
  Array.wrap(source_files).map do |filename|
    ::File.join mod_path, source_dir, filename
  end
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
