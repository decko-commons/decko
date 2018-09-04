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

        def layout layout, &block
          Card::Layout.register_built_in_layout layout
          method_name = Card::Set::Format.layout_method_name(layout)
          define_method method_name, &block
          wrapper layout do
            send method_name
          end
          # define_method "#{method_name}_with_main" do
          #   wrap_main do
          #      send method_name
          #    end
          # end
          # define_wrap_with_method layout, "#{method_name}_with_main"


          #class_exec do
            # define_method "wrap_with_#{layout}" do |&block|
            #   wrap_main do
            #     send method_name
            #   end
            # end
          #end
          # instance_exec(self) do |format|
          #   wrapper layout do
          #     format.wrap_main &block
          #       #send Card::Set::Format.layout_method_name(layout)
          #     #)
          #     #::Card::Layout.render layout, self)
          #   end
          # end

        end

        attr_accessor :interiour

        private

        # expects a tag with options that defines the wrap
        def define_tag_wrapper method_name, tag_name, default_opts={}
          class_eval do
            define_method method_name do |opts={}|
              add_class opts, default_opts[:class]
              wrap_with(tag_name, interiour, opts.reverse_merge(default_opts))
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
              #instance_variable_set "@interiour", @interiour
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
