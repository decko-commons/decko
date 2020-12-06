def source_files
  db_content
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
      Rails.logger.debug "reading file: #{source_path}"
      ::File.read source_path
    end
  end.compact.join "\n"
end

def virtual?
  true
end


def compress_js?
  @minimize
end

def minimize
  @minimze = true
end

def local
  @local = true
end

format do
  def link_view opts={}
    opts[:path] = { card: { type: card.type, content: card.db_content}}
    link_to_card card.name, _render_title, opts
  end

  def link_to_view view, text=nil, opts={}
    opts[:path] = { card: { type: card.type, content: card.db_content}}
     super view, (text || view), opts
   end
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
      wrap_with(:span, "asset file", class: "text-muted")
  end

  def standard_submit_button
    multi_card_editor? ? super : ""
  end
end
