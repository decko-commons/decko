class Card
  class Bootstrap
    class Component
      class HorizontalForm < Form
        def left_col_width
          @child_args.last && @child_args.last[0] || 2
        end

        def right_col_width
          @child_args.last && @child_args.last[1] || 10
        end

        def_tag_method :form, "form-horizontal"

        def_tag_method :label, "control-label" do |opts, _extra_args|
          prepend_class opts, "col-sm-#{left_col_width}"
          opts
        end

        # def_div_method :input, nil do |opts, extra_args, &block|
        #   type, label = extra_args
        #   prepend { tag(:label, nil, for: opts[:id]) { label } } if label
        #   insert { inner_input opts.merge(type: type) }
        #   { class: "col-sm-#{right_col_width}" }
        # end

        def label_col label, id: nil
          @html.label label, for: id, class: "col-sm-#{left_col_width} control-label"
        end

        def input type, label: nil, id: nil
          label_col label, id: id
          @html.div class: "col-sm-#{right_col_width}" do
            @html.input type: type, id: id, class: "form-control"
          end
          # block.call class: "col-sm-#{right_col_width}" do
          #   inner_input opts.merge(type: type)
          # end
        end

        def_tag_method :inner_input, "form-control", tag: :input
        def_div_method :inner_checkbox, "checkbox"

        def_div_method :checkbox, nil do |opts, extra_args|
          inner_checkbox do
            label do
              inner_input "checkbox", extra_args.first, opts
            end
          end
          { class: "col-sm-offset-#{left_col_width} col-sm-#{right_col_width}" }
        end

        def checkbox _text, _extra_args
          @html.div class: "col-sm-offset-#{left_col_width} col-sm-#{right_col_width}" do
            @html.div class: "checkbox" do
              label_cllabel do
                inner_input "checkbox"
              end
            end
          end
        end
      end
    end
  end
end
