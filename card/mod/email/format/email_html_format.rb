# -*- encoding : utf-8 -*-

class Card
  class Format
    class EmailHtmlFormat < Card::Format::HtmlFormat
      @@aliases["email"] = "email_html"

      def self.view_caching?
        false
      end
    end
  end
end
