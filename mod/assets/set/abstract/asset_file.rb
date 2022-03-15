include_set Abstract::CodeFile

attr_accessor :base_path

def source_paths
  source_files.map do |file|
    ::File.join base_path, file
  end
end

def files_must_exist!
  source_paths.select do |path|
    raise Card::Error, "couldn't locate asset file: #{path}" if unknown_file? path
  end
end

def source_files
  [db_content]
end

def find_file path
  path.tap do |file_path|
    return nil if unknown_file? file_path
  end
end

def unknown_file? file_path
  return false if ::File.exist? file_path

  Rails.logger.info "couldn't locate #{file_path}"
  true
end

def virtual?
  true
end

def new?
  false
end

format do
  def link_view opts={}
    opts[:path] = { card: { type: card.type, content: card.db_content } }
    link_to_card card.name, _render_title, opts
  end

  def link_to_view view, text=nil, opts={}
    opts[:path] = { card: { type: card.type, content: card.db_content } }
    super view, (text || view), opts
  end
end

format :html do
  view :javascript_include_tag do
    card.existing_source_paths.map do |path|
      javascript_include_tag(path)
    end.join "\n"
  end

  def short_content
    fa_icon("exclamation-circle", class: "text-muted pr-2") +
      wrap_with(:span, "asset file", class: "text-muted")
  end
end
