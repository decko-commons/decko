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
        if rel_path =~ %r{^(https?\:)?/}
          rel_path
        else
          "#{Card.config.relative_url_root}/#{rel_path}"
        end
      end

      def card_url rel
        if rel =~ /^https?\:/
          rel
        else
          "#{Card::Env[:protocol]}#{Card::Env[:host]}#{card_path rel}"
        end
      end

      extend Location # ??
    end
  end
end
