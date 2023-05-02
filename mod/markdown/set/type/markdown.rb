require "kramdown"
require 'kramdown-syntax-coderay'

format :html do
  view :core do
    safe_process_content do |content|
      Kramdown::Document.new(content, syntax_highlighter: :coderay,
                             syntax_highlighter_opts: {
                               line_numbers: false,
                               default_lang: :ruby}).to_html
    end
  end

  def escape_literal literal
    literal
  end

  def input_type
    :ace_editor
  end

  def ace_mode
    :markdown
  end
end
