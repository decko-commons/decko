class Card
  module Set
    module Format
      # The Wrapper module provides an API to define wrap methods
      #
      # Example:
      # To define a wrapper call wrapper in a format block like this:
      # wrapper :burger do |interiour, opts|
      #   ["#{opts[:bun]}-bun", interiour, "bun"].join "|"
      # end
      #
      # It can be used like this:
      # wrap_with_burger bun: "sesame" do
      #   "meat"
      # end  # => "sesame-bun|meat|bun"
      #
      # It's also possible to wrap a whole view with
      # view :whopper, wrap: :burger do
      #   "meat"
      # end
      #
      # Options are not supported in the latter case.
      #
      # If you want to wrap only with a single html tag you can use the following syntax:
      # wrapper :burger, :div, class: "medium"
      #
      # wrap_with_burger "meat"  # => "<div class='medium'>meat</div>"
      module Wrapper
        def wrapper wrapper_name, *args, &wrap_block
          method_name = Card::Set::Format.wrapper_method_name(wrapper_name)
          if block_given?
            # define_method method_name do |_interiour, opts={}|
            #               wrap_block.call opts
            #             end
            define_method method_name, &wrap_block
            #define_block_wrapper method_name, &wrap_block
          else
            define_tag_wrapper method_name, *args
          end
          define_wrap_with_method wrapper_name, method_name
        end

        attr_accessor :interiour

        private

        # expects a tag with options that defines the wrap
        def define_tag_wrapper method_name, tag_name, default_opts
          class_eval do
            define_method method_name do |interiour, opts={}|
              content_tag tag_name, interiour, default_opts.merge(opts)
            end
          end
        end

        # expects a block that defines the wrap
        def define_block_wrapper method_name, &wrap_block
          #class_eval do
          # define_method method_name do |_interiour, opts={}|
          wrap_block.call opts
          # end
        end

        # defines the wrap_with_... method that you call to use the wrapper
        def define_wrap_with_method wrapper_name, wrapper_method_name
          class_exec(self) do |format|
            define_method "wrap_with_#{wrapper_name}" do |*args, &interiour|
              @interiour, opts =
                if interiour
                  [interiour.call, args.first]
                else
                  args
                end
              if method(wrapper_method_name).arity.zero?
                send wrapper_method_name
              else
                opts ||= {}
                send wrapper_method_name, opts
              end
            end
          end
        end
      end
    end
  end
end
