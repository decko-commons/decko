module Patches
  module ActiveJob
    # monkeypatch ActiveJob so that it can handle more types of arguments
    module Arguments
      CLASS_NAME_KEY = "_aj_class_name_key".freeze

      private

      def serialize_argument argument
        case argument
        when Symbol, Time, DateTime
          { value: argument.to_s, CLASS_NAME_KEY => argument.class.to_s }
        when ActionController::Parameters
          { value: serialize_argument(argument.to_unsafe_h),
            CLASS_NAME_KEY: argument.class.to_s }
        else
          super
        end
      end

      def deserialize_argument argument
        return super unless argument.is_a?(Hash) &&
                            argument[CLASS_NAME_KEY]
        argument_class = Object.const_get argument[CLASS_NAME_KEY]
        case argument_class
        when Symbol
          argument[:value].to_sym
        when Time, DateTime
          argument_class.parse argument[:value]
        else
          argument[:value]
        end
      end
    end
  end
end