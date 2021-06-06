# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    # methods shared across Generator bases (which inherit from Rails generator classes)
    module ClassMethods
      def source_root path=nil
        if path
          @_card_source_root = path
        else
          @_card_source_root ||= File.expand_path(
            "../../../generators/card/#{generator_name}/templates", __FILE__
          )
        end
      end

      # Override Rails default banner (using card/decko for the command name).
      def banner
        usage_arguments = arguments.map(&:usage).join " "
        text = "#{banner_command} generate #{namespace} #{usage_arguments} [options]"
        text.gsub(/\s+/, " ")
      end

      def banner_command
        "card"
      end

      # Override Rails namespace handling so we can put generators in `module Cardio`
      def namespace name=nil
        return super if name
        @namespace ||= super.sub(/cardio:/, "")
      end
    end
  end
end
