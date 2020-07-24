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
      def clean_tags string, tags
        # $LAST_MATCH_INFO is nil if string is a SafeBuffer
        string.to_str.gsub(%r{<(/*)(\w+)([^>]*)>}) do |raw|
          raw = $LAST_MATCH_INFO
          tag = raw[2].downcase
          if (attrs = tags[tag])
            html_attribs =
              attrs.each_with_object([tag]) do |attr, pcs|
                q, rest_value = process_attribute attr, raw[3]
                pcs << "#{attr}=#{q}#{rest_value}#{q}" unless rest_value.blank?
              end * " "
            "<#{raw[1]}#{html_attribs}>"
          else
            " "
          end
        end.gsub(/<\!--.*?-->/, "")
      end

      def clean_spaces string
        string.gsub(/(?:^|\b) ((?:&nbsp;)+)/, '\1 ')
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
