class Card
  class Content
    # tools for cleaning content, especially for restricing unwanted HTML
    module Clean
      allowed_tags = {}
      %w[
        br i b pre cite caption strong em ins sup sub del ol hr ul li p
        div h1 h2 h3 h4 h5 h6 span table tr td th tbody thead tfoot
      ].each { |tag| allowed_tags[tag] = [] }

      # allowed attributes
      allowed_tags.merge!(
        "a" => %w[href title target],
        "img" => %w[src alt title],
        "code" => ["lang"],
        "blockquote" => ["cite"]
      )

      if Cardio.config.allow_inline_styles
        allowed_tags["table"] += %w[cellpadding align border cellspacing data-mce-style]
        allowed_tags["td"] += %w[scope data-mce-style]
        allowed_tags["th"] += %w[scope data-mce-style]
      end

      allowed_tags.each_key do |k|
        allowed_tags[k] << "class"
        allowed_tags[k] << "style" if Cardio.config.allow_inline_styles
        allowed_tags[k]
      end

      ALLOWED_TAGS = allowed_tags.freeze

      ATTR_VALUE_RE = [/(?<=^')[^']+(?=')/, /(?<=^")[^"]+(?=")/, /\S+/].freeze

      def clean! string, tags=ALLOWED_TAGS
        cleaned = clean_tags string, tags
        cleaned = clean_spaces cleaned if Cardio.config.space_last_in_multispace
        cleaned
      end

      private

      ## Method that cleans the String of HTML tags
      ## and attributes outside of the allowed list.
      def clean_tags string, ok_tags
        # $LAST_MATCH_INFO is nil if string is a SafeBuffer
        string.to_str.gsub(%r{<(/*)(\w+)([^>]*)>}) do |_raw|
          clean_tag $LAST_MATCH_INFO, ok_tags
        end.gsub(/<\!--.*?-->/, "")
      end

      def clean_spaces string
        string.gsub(/(?:^|\b) ((?:&nbsp;)+)/, '\1 ')
      end

      def clean_tag match, ok_tags
        tag = match[2].downcase
        return " " unless (ok_attrs = ok_tags[tag])
        "<#{match[1]}#{html_attribs tag, match[3], ok_attrs}>"
      end

      def html_attribs tag, raw_attr, ok_attrs
        ok_attrs.each_with_object([tag]) do |ok_attr, pcs|
          q, rest_value = process_attribute ok_attr, raw_attr
          pcs << "#{ok_attr}=#{q}#{rest_value}#{q}" unless rest_value.blank?
        end * " "
      end

      def process_attribute attrib, all_attributes
        return ['"', nil] unless all_attributes =~ /\b#{attrib}\s*=\s*(?=(.))/i

        q = '"'
        rest_value = $'
        if (idx = %w[' "].index Regexp.last_match(1))
          q = Regexp.last_match(1)
        end
        reg_exp = ATTR_VALUE_RE[idx || 2]
        rest_value = process_attribute_match rest_value, reg_exp, attrib
        [q, rest_value]
      end

      # NOTE allows classes beginning with "w-" (deprecated)
      def process_attribute_match rest_value, reg_exp, attrib
        return rest_value unless (match = rest_value.match reg_exp)

        rest_value = match[0]
        if attrib == "class"
          rest_value.split(/\s+/).select { |s| s =~ /^w-/i }.join(" ")
        else
          rest_value
        end
      end
    end
  end
end
