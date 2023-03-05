class Card
  module Set
    module Format
      module AbstractFormat
        # The Wrapper module provides an API to define wrap methods.
        # It is available in all formats.
        module Wrapper
          # Defines a wrapper method with the name "wrap_with_<wrapper_name>".
          # @param wrapper_name [Symbol, String] the name for the wrap method
          #
          # Inside the wrap_block the variable "interior" is always available
          # to refer to the content that is supposed to be wrapped by the wrapper.
          #
          # Example:
          #   wrapper :burger do |opts|
          #     ["#{opts[:bun]}-bun", interior, "bun"].join "|"
          #   end
          #
          # It can be used like this:
          #   wrap_with_burger bun: "sesame" do
          #     "meat"
          #   end  # => "sesame-bun|meat|bun"
          #
          # It's also possible to wrap a whole view with a wrapper
          #   view :whopper, wrap: :burger do
          #     "meat"
          #   end
          #
          # Options for view wrappers can be provided using a hash or, if not all wrappers
          # need options, an array of symbols and hashes.
          # Example
          #   view :big_mac, wrap: { burger: { bun: "sesame" }, paper: { color: :red } }
          #   view :cheese_burger, wrap: [:burger, paper: { color: :yellow }]
          #
          # If you want to define a wrapper that wraps only with a single html tag
          # then use the following syntax:
          #   wrapper :burger, :div, class: "medium"
          #
          #   wrap_with_burger "meat"  # => "<div class='medium'>meat</div>"
          def wrapper wrapper_name, *args, &wrap_block
            method_name = Card::Set::Format.wrapper_method_name(wrapper_name)
            if block_given?
              define_method method_name, &wrap_block
            else
              define_tag_wrapper method_name, *args
            end
            define_wrap_with_method wrapper_name, method_name
          end

          def layout layout, opts={}, &block
            Card::Layout.register_built_in_layout layout, opts
            method_name = Card::Set::Format.layout_method_name(layout)
            define_method method_name, &block
            wrapper layout do
              send method_name
            end
          end

          attr_accessor :interior

          private

          # expects a tag with options that defines the wrap
          def define_tag_wrapper method_name, tag_name, default_opts={}
            class_eval do
              define_method method_name do |opts={}|
                add_class opts, default_opts[:class]
                wrap_with(tag_name, interior, opts.reverse_merge(default_opts))
              end
            end
          end

          # defines the wrap_with_... method that you call to use the wrapper
          def define_wrap_with_method wrapper_name, wrapper_method_name
            class_exec(self) do |_format|
              define_method "wrap_with_#{wrapper_name}" do |*args, &interior|
                voo.interior, opts = interior ? [interior.call, args.first] : args
                send_wrapper_method wrapper_method_name, opts
              end
            end
          end
        end
      end
    end
  end
end
