module Decko
  module Generators
    module Deck
      class DeckGenerator
        ### the following is straight from rails and is focused on checking
        # the validity of the app name.needs decko-specific tuning
        module RailsOverrides
          protected

          def app_name
            @app_name ||=
              defined_app_const_base? ? defined_app_name : File.basename(destination_root)
          end

          def defined_app_name
            defined_app_const_base.underscore
          end

          def defined_app_const_base
            Rails.respond_to?(:application) && defined?(Rails::Application) &&
                Decko.application.is_a?(Rails::Application) &&
                Decko.application.class.name.sub(/::Application$/, "")
          end

          alias defined_app_const_base? defined_app_const_base

          def app_const_base
            @app_const_base ||= defined_app_const_base ||
                app_name.gsub(/\W/, "_").squeeze("_").camelize
          end

          alias camelized app_const_base

          def app_const
            @app_const ||= "#{app_const_base}::Application"
          end

          def valid_const?
            if app_const =~ /^\d/
              invalid_app_name "Please give a name which does not start with numbers."
            elsif Object.const_defined?(app_const_base)
              invalid_app_name "constant #{app_const_base} is already in use. " \
                               "Please choose another application name."
            end
          end

          def invalid_app_name message
            raise Thor::Error, "Invalid application name #{app_name}, #{message}"
          end
        end
      end
    end
  end
end
