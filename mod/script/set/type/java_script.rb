# -*- encoding : utf-8 -*-

include_set Abstract::JavaScript

ANSI_COLOR_CODE = {
  0 => 'black',
  1 => 'red',
  2 => 'green',
  3 => 'yellow',
  4 => 'blue',
  5 => 'purple',
  6 => 'cyan',
  7 => 'white'
}

# translate bash color codes to html
# source: https://gist.github.com/pocha/5114797
def sanitize_ansi_data(data)
  data.gsub!(/\033\[1m/,"<b>")
  data.gsub!(/\033\[0m/,"</b></span>")

  data.gsub!(/\033\[[\d\;]{2,}m.*?<\/b><\/span>/){ |data|
    span = "<span style='"
    content = ""
    /\033\[([\d\;]{2,})m(.*?)<\/b><\/span>/.match(data) {|m|
      content = m[2]
      m[1].split(";").each do |code|
        #puts code
        if match = /(\d)(\d)/.match(code)
          case match[1]
          when "3"
            span += "color: #{ANSI_COLOR_CODE[match[2].to_i]}; "
          when "4"
            span += "background-color: #{ANSI_COLOR_CODE[match[2].to_i]}; "
          else
            #do nothing
          end
        else
          span += "font-weight:bold; "
        end
      end
    }
    span += "'>"
    "#{span}#{content}</b></span>"
  }
  data
end

event :validate_javascript_sytnax, :validate, on: :save, changed: %i[type_id content] do
  Uglifier.compile content, harmony: true
rescue Uglifier::Error => e
  errors.add :content, "<pre>#{sanitize_ansi_data(e.message)}</pre>".html_safe
end