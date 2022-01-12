class Card
  module Env
    # serializing environment (eg for delayed jobs)
    module Serialization
      def serializable_methods
        Serializable.instance_methods + %i[main_name params]
      end

      def serialize
        @serialized = serializable_methods.each_with_object({}) do |attr, hash|
          hash[attr] = send attr
        end
      end

      # @param serialized_env [Hash]
      def with serialized_env
        tmp_env = serialize
        @env ||= {}
        @env.update serialized_env
        yield
      ensure
        @env.update tmp_env if tmp_env
      end

      # supercede serializable methods when serialized values are available
      #
      # note - at present this must be done manually when adding serializable methods
      # in mods.
      serializable_methods.each do |attrib|
        define_method attrib do
          @serialized&.key?(attrib) ? @serialized[attrib] : super()
        end
      end
    end
  end
end
