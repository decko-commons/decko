# -*- encoding : utf-8 -*-

require_dependency "card/content/diff"

class Card
  class Format
    # Main Format class for formatting card views in HTML
    class HtmlFormat < Format
      register :html

      attr_accessor :options_need_save, :start_time, :skip_autosave

      def main?
        !@main.nil?
      end

      # is the current card the requested card?
      def focal?
        show_layout? ? main? : depth.zero?
      end

      def default_nest_view
        # FIXME: not sure this makes sense as a rule...
        card.rule(:default_html_view) || :titled
      end

      def default_item_view
        :closed
      end

      def mime_type
        "text/html"
      end
    end
  end
end
