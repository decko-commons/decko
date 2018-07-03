# -*- encoding : utf-8 -*-

require_dependency "card/content/diff"

class Card
  class Format
    class HtmlFormat < Format
      register :html

      attr_accessor :options_need_save, :start_time, :skip_autosave

      # TODO: use CodeFile cards for these
      # builtin layouts allow for rescue / testing
      HTML_LAYOUTS = Mod::Loader.load_layouts(:html).merge "none" => "{{_main}}"
      HAML_LAYOUTS = Mod::Loader.load_layouts(:haml)

      def main?
        !@main.nil?
      end

      def focal? # meaning the current card is the requested card
        show_layout? ? main? : depth.zero?
      end

      def default_nest_view
        # FIXME: not sure this makes sense as a rule...
        card.rule(:default_html_view) || :titled
      end

      def default_item_view
        :closed
      end

      def process_layout layout_name
        layout_name ||= layout_name_from_rule
        send "process_#{layout_type layout_name}_layout", layout_name
      end

      def process_haml_layout layout
      end

      def process_content_layout layout_name
        content = layout_from_card_or_code layout_name
        process_content content, chunk_list: :references
      end

      def layout_type layout_name
        HAML_LAYOUTS[layout_name.to_s].present? ? :haml : :content
      end

      def layout_name_from_rule
        card.rule_card(:layout)&.try :item_name
      end

      def layout_from_card_or_code layout_name
        layout_card_content(layout_name) || HTML_LAYOUTS(layout_name) || unknown_layout
      end

      def layout_card_content layout_name
        layout_card = Card.quick_fetch layout_name
        return unless layout_card.type_id == Card::LayoutTypeID
        layout_card.content
      end

      def unknown_layout
        output [
          content_tag(:h1, I18n.t(:unknown_layout,
                                  scope: "mod.core.format.html_format",
                                  name: name)),
          I18n.t(:built_in,
                 scope: "mod.core.format.html_format",
                 built_in_layouts: LAYOUTS.keys.join(', '))
        ]
      end

      def html_escape_except_quotes s
        # to be used inside single quotes (makes for readable json attributes)
        s.to_s.gsub(/&/, "&amp;").gsub(/\'/, "&apos;")
         .gsub(/>/, "&gt;").gsub(/</, "&lt;")
      end

      def mime_type
        "text/html"
      end
    end
  end
end
