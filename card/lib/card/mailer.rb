# -*- encoding : utf-8 -*-

require "open-uri"

class Card
  class Mailer < ActionMailer::Base
    class << self
      def new_mail *args, &block
        Mail.new(args, &block).tap do |mail|
          method = Card::Mailer.delivery_method
          mail.delivery_method(method, send(:"#{method}_settings"))
          mail.perform_deliveries    = perform_deliveries
          mail.raise_delivery_errors = raise_delivery_errors
        end
      end

      def layout message
        <<-HTML
          <!DOCTYPE html>
          <html>
            <head>
              <meta http-equiv="Content-type" content="text/html;charset=UTF-8"/>
            </head>
            <body>
              #{message}
            </body>
          </html>
        HTML
      end

      def defaults_from_config
        (Card.config.email_defaults || {}).symbolize_keys.tap do |defaults|
          defaults[:return_path] ||= defaults[:from] if defaults[:from]
          defaults[:charset] ||= "utf-8"
        end
      end
    end

    default defaults_from_config
  end
end
