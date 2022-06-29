include_set Abstract::Scss
include_set Abstract::AssetInputter, input_format: :scss

event :validate_scss_syntax, :validate, on: :save, changed: %i[type_id content] do
  variables = Card[:all, :style].joined_items_content
  SassC::Engine.new([variables.strip, content].join("\n")).render
rescue SassC::SyntaxError => e
  match = e.message.match(/line (\d+)/)
  message =
    if match
      offset = 6
      corrected_line = match[1].to_i - variables.lines.count + offset
      e.message
       .sub(/line \d+:(\d+) of stdin/, "line #{corrected_line}:\\1")
       .sub(/>>.*$/, ">> #{content.lines[corrected_line - 1]}")
      # e.message
    else
      e.message
    end
  errors.add(:content, "<pre>#{message}</pre>".html_safe)
end