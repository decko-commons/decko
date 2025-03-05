class Card
  class Bootstrap
    class Component
      # support class for bootstrap forms
      class Form < Component
        def render_content *args
          form(*args, &@build_block)
        end

        #
        # def_tag_method :form, nil, optional_classes: {
        #   horizontal: "form-horizontal",
        #   inline: "form-inline"
        # }
        # def_div_method :group, "form-group"
        # def_tag_method :label, nil
        # def_tag_method :input, "form-control" do |opts, extra_args|
        #   type, label = extra_args
        #   prepend { label label, for: opts[:id] } if label
        #   opts[:type] = type
        #   opts
        # end

        def form opts={}, &block
          add_class opts, "form-horizontal" if opts.delete(:horizontal)
          add_class opts, "form-inline" if opts.delete(:inline)
          @html.form opts do
            instance_exec(&block)
          end
        end

        def group text=nil, &block
          @html.div text, class: "form-group" do
            instance_exec(&block)
          end
        end

        def label text=nil, &block
          @html.label text, &block
        end

        def input type, text: nil, label: nil, id: nil
          @html.input id: id, class: "form-control", type: type do
            @html.label label, for: id if label
            @html << text if text
          end
        end

        %i[text password datetime datetime-local date month time
           week number email url search tel color].each do |tag|
          # def_tag_method tag, "form-control", attributes: { type: tag },
          #                                     tag: :input do |opts, extra_args|
          #   label, = extra_args
          #   prepend { label label, for: opts[:id] } if label
          #   opts
          # end

          define_method tag do |id:, label:, text: nil|
            @html.input id: id, class: "form-control", type: tag do
              @html.label label, for: id if label
              @html << text
            end
          end
        end
      end
    end
  end
end
