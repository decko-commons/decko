# -*- encoding : utf-8 -*-

class Card
  class Format
    # card format class for rss (really simple syndication) views
    class RssFormat < HtmlFormat
      register :rss
    end
  end
end
