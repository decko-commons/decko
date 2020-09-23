require 'kramdown'

format :html do
  view :core do
    safe_process_content do |content|
      Kramdown::Document.new(content).to_html
    end
  end

  def input_type
    :ace_editor
  end

  def ace_mode
    :markdown
  end
end
