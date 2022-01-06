class Card
  module Env
    # serializing environment (eg for delayed jobs)
    module Serialization
      SERIALIZABLE_ATTRIBUTES = ::Set.new %i[
        main_name params ip ajax html host protocol origin
      ]

      SERIALIZABLE_ATTRIBUTES.each do |attrib|
        define_method attrib do
          if @serialized&.key? attrib
            @serialized[attrib]
          else
            super()
          end
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

      def serialize
        @serialized = SERIALIZABLE_ATTRIBUTES.each_with_object({}) do |attr, hash|
          hash[attr] = send attr
        end
      end
    end
  end
end
