class Card
  module Env
    # utility methods for Card::Env
    module Support
      def with_params hash
        old_params = params.clone
        params.merge! hash
        yield
      ensure
        @params = old_params
      end

      def hash hashish
        case hashish
        when Hash then hashish.clone
        when ActionController::Parameters then hashish.to_unsafe_h
        else {}
        end
      end

      def reset_session
        if session.is_a? Hash
          @session = {}
        elsif request
          update_cookie_setting false
          controller.reset_session
          # destroy_cookie unless Cardio.config.anonymous_cookies
        end
      end

      def update_cookie_setting is_anonymous=true
        return unless request && !Cardio.config.anonymous_cookies

        request.session_options[:drop] = is_anonymous
      end

      # private

      # FIXME: not working
      # the response generally works to destroy a cookie, but
      # the deletion doesn't appear to work in a redirect. Since signing out
      # has a redirect response, we're still left with a cookie
      # def destroy_cookie
      #   app = Cardio.application
      #   app_name = app.class.name ? app.railtie_name.chomp("_application") : ""
      #   expire_in_past = "expires=Thu, 01 Jan 1970 00:00:00 GMT;"
      #   controller.response.set_header "SET-COOKIE",
      #                                  "_#{app_name}_session=deleted; #{expire_in_past}"
      # end
    end
  end
end
