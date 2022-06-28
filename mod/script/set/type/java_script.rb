# -*- encoding : utf-8 -*-

include_set Abstract::JavaScript

# translate bash color codes to html
# source: https://gist.github.com/pocha/5114797
ANSI_COLOR_CODE = {
  0 => "black",
  1 => "red",
  2 => "green",
  3 => "yellow",
  4 => "blue",
  5 => "purple",
  6 => "cyan",
  7 => "white"
}.freeze

def sanitize_ansi_data data
  data.gsub(/\033\[1m/, "<b>")
      .gsub(/\033\[0m/, "</b></span>")
      .gsub(/\033\[[\d\;]{2,}m.*?<\/b><\/span>/) { |match| adjust_span match }
end

def adjust_span data
  style = ""
  content = ""
  /\033\[([\d\;]{2,})m(.*?)<\/b><\/span>/.match(data) do |m|
    content = m[2]
    m[1].split(";").each { |code| style += translate_style_code code }
  end
  "<span style='#{style}'>#{content}</b></span>"
end

def translate_style_code code
  if (match = /(\d)(\d)/.match(code))
    property =
      case match[1]
      when "3"
        "color"
      when "4"
        "background-color"
      else
        return
      end
    "#{property}: #{ANSI_COLOR_CODE[match[2].to_i]};  "
  else
    "font-weight:bold; "
  end
end

event :validate_javascript_sytnax, :validate, on: :save, changed: %i[type_id content] do
  Uglifier.compile content, harmony: true
rescue Uglifier::Error => e
  errors.add :content, "<pre>#{sanitize_ansi_data(e.message)}</pre>".html_safe
end