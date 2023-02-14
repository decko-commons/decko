# Converts ansi formatting codes to html
module Cardio
  module Utils
    # convert ANSI to html
    module Ansi2Html
      def ansi2html data
        data.gsub(/\033\[(?<code>[\d\;]{2,})m(?<content>.*?)\033\[0m/) do
          to_span_tag Regexp.last_match(:code), Regexp.last_match(:content)
        end
      end

      private

      ANSI_COLOR_CODE = {
        0 => "black",
        1 => "red",
        2 => "green",
        3 => "gold",
        4 => "blue",
        5 => "magenta",
        6 => "darkcyan",
        7 => "white"
      }.freeze

      ANSI_BRIGHT_COLOR_CODE = {
        0 => "gray",
        1 => "lightcoral",
        2 => "lightgreen",
        3 => "lightyellow",
        4 => "lightblue",
        5 => "mediumpurple",
        6 => "lightcyan",
        7 => "lightgray"
      }.freeze

      STYLE_MAPPINGS = {
        1 => "font-weight:bold",
        2 => "opacity:0.5",
        3 => "font-style:italic",
        4 => "text-decoration:underline",
        5 => "text-decoration:blink",
        6 => "text-decoration:blink",
        9 => "text-decoration:line-through"
      }.freeze

      def to_span_tag codes, content
        style = codes.split(";")
                     .map(&method(:translate_style_code))
                     .join
        "<span style='#{style}'>#{content}</span>"
      end

      def translate_style_code code
        return STYLE_MAPPINGS[code.to_i] if code.size == 1

        color_code = code[-1].to_i
        property, mapping =
          case code[0..-2]
          when "3"
            ["color", ANSI_COLOR_CODE]
          when "4"
            ["background-color", ANSI_COLOR_CODE]
          when "9"
            ["color", ANSI_BRIGHT_COLOR_CODE]
          when "10"
            ["background-color", ANSI_BRIGHT_COLOR_CODE]
          end
        "#{property}: #{mapping[color_code]}; "
      end

      Utils.extend self
    end
  end
end
