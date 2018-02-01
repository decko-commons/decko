class Card
  module Set
    module Format
      TEMPLATE_DIR = %w[template set].freeze

      # Support haml templates in a Rails like way:
      # If the view option `template: :haml` is set then wagn expects a haml template
      # in a corresponding template path and renders it.

      #
      # @example
      #   # mod/core/set/type/basic.rb
      #   view :my_view, template: :haml  # renders mod/core/view/type/basic/my_view.haml
      #
      #   view :with_instance_variables, template: :haml do
      #     @actor = "Mark Haml"
      #   end
      #
      #   # mod/core/view/type/basic/with_instance_variables.haml
      #   Luke is played by
      #     = actor
      #
      #   > render :with_instance_variables  # => "Luke is played by Mark Haml"
      module HamlViews
        def haml_view_block view, wrap_with_slot, &block
          path = haml_template_path view
          haml_template_proc ::File.read(path), path, wrap_with_slot, &block
        end

        def haml_template_proc template, path, wrap_with_slot, &block
          proc do |view_args|
            with_template_path path do
              locals = haml_block_locals view_args, &block
              html = haml_to_html template, locals, nil, path: path
              wrap_with_slot ? wrap { html } : html
            end
          end
        end

        def haml_block_locals view_args, &block
          return view_args unless block_given?
          instance_exec view_args, &block
          instance_variables.each_with_object({}) do |var, h|
            h[var.to_s.tr("@", "").to_sym] = instance_variable_get var
          end
        end

        def haml_template_path view=nil, source=nil
          each_template_path(source) do |template_dir, source_dir|
            path = try_haml_template_path template_dir, view, source_dir
            return path if path
          end
          msg = "can't find haml template"
          msg += " for #{view}" if view.present?
          raise Card::Error, msg
        end

        def each_template_path source
          source ||= source_location
          basename = ::File.basename source, ".rb"
          source_dir = ::File.dirname source
          ["./#{basename}", "."].each do |template_dir|
            yield template_dir, source_dir
          end
        end

        def try_haml_template_path template_path, view, source_dir, ext="haml"
          template_path = File.join(template_path, view.to_s) if view.present?
          template_path += ".#{ext}"
          TEMPLATE_DIR.each do |template_dir|
            path = ::File.expand_path(template_path, source_dir)
                         .sub(%r{(/mod/[^/]+)/set/}, "\\1/#{template_dir}/")
            return path if ::File.exist?(path)
          end
          false
        end

        def haml_to_html haml, locals={}, a_binding=nil, debug_info={}
          # binding.pry unless haml.include? ".panel.panel-primary"
          a_binding ||= binding
          ::Haml::Engine.new(haml).render a_binding, locals || {}
        rescue Haml::SyntaxError => e
          raise Card::Error,
                "haml syntax error #{template_location(debug_info)}: #{e.message}"
        end

        def template_location debug_info
          return "" unless debug_info[:path]
          Pathname.new(debug_info[:path])
                  .relative_path_from(Pathname.new(Dir.pwd))
        end

        def with_template_path path
          old_path = @template_path
          @template_path = path
          yield
        ensure
          @template_path = old_path
        end
      end
    end
  end
end
