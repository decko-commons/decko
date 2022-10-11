class Card
  module Set
    module Format
      # methods for handling paths to HAML templates
      module HamlPaths
        delegate :tmp_files?, to: Cardio::Mod::LoadStrategy

        def haml_to_html haml, locals={}, a_binding=nil, debug_info={}
          a_binding ||= binding
          ::Haml::Engine.new(haml).render a_binding, locals || {}
        rescue Haml::SyntaxError => e
          raise Card::Error,
                "haml syntax error #{template_location(debug_info)}: #{e.message}"
        end

        def with_template_path path
          old_path = @template_path
          @template_path = path
          yield
        ensure
          @template_path = old_path
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

        def template_location debug_info
          return "" unless debug_info[:path]

          Pathname.new(debug_info[:path]).relative_path_from(Pathname.new(Dir.pwd))
        end

        def each_template_path source
          source = deep_source(source) || source_location
          basename = ::File.basename source, ".rb"
          source_dir = ::File.dirname source
          ["./#{basename}", "."].each do |template_dir|
            yield template_dir, source_dir
          end
        end

        TMPSET_REGEXP = %r{^.*/tmp(sets)?/set/\w+/mod\d{3}-(?<modname>[^/]+)}

        def deep_source source
          return source unless tmp_files?

          source&.sub TMPSET_REGEXP do
            "#{Cardio::Mod.fetch(Regexp.last_match[:modname]).path}/set"
          end
        end

        def try_haml_template_path template_path, view, source_dir, ext="haml"
          template_path = File.join(template_path, view.to_s) if view.present?
          template_path += ".#{ext}"
          path = ::File.expand_path(template_path, source_dir)
          path if ::File.exist? path
        end

        def haml_block_locals &block
          instance_exec(&block) if block_given?
          instance_variables.each_with_object({}) do |var, h|
            h[var.to_s.tr("@", "").to_sym] = instance_variable_get var
          end
        end
      end
    end
  end
end
