# -*- encoding : utf-8 -*-

module Cardio
  module Generators
    module ClassMethods
      def source_root path=nil
        if path
          @_card_source_root = path
        else
          @_card_source_root ||= File.expand_path(
            File.join(File.dirname(__FILE__),
                      "card", generator_name, "templates")
          )
        end
      end

      # Override Rails default banner (decko is the command name).
      def banner
        usage_arguments = arguments.map(&:usage) * " "
        text = "decko generate #{namespace} #{usage_arguments} [options]"
        text.gsub(/\s+/, " ")
      end

      def namespace(name = nil)
        return super if name
        @namespace ||= super.sub(/cardio:/, "")
      end
    end
  end
end
