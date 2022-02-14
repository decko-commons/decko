class Card
  module Env
    module Location
      # card_path    makes a relative path site-absolute (if not already)
      # card_url     makes it a full url (if not already)

      def card_path rel_path
        unless rel_path.is_a? String
          Rails.logger.warn "Pass only strings to card_path. "\
                            "(#{rel_path} = #{rel_path.class})"
        end
        if rel_path.match? %r{^(https?:)?/}
          rel_path
        else
          "#{relative_url_root}/#{rel_path}"
        end
      end

      def card_url rel
        rel.match?(/^https?:/) ? rel : "#{Env.origin}#{card_path rel}"
      end

      def cardname_from_url url
        return unless (cardname = cardname_from_url_regexp)

        m = url.match cardname
        m ? Card::Name[m[:mark]] : nil
      end

      def relative_url_root
        Cardio.config.relative_url_root
      end

      private

      def cardname_from_url_regexp
        return unless Env.origin.present?

        %r{#{Regexp.escape Env.origin}/(?<mark>[^?]+)}
      end

      extend Location # allows calls on Location constant, eg Location.card_url
    end
  end
end
