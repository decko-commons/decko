class Card
  module Set
    module Format
      # handles processing of view definition options
      module ViewOpts
        VIEW_SETTINGS = %i[cache bridge wrap perms denial closed].freeze
        VIEW_DEFINITION_OPTS = %i[alias_to mod template async].freeze

        private

        def process_view_opts view, args
          def_opts, opts = normalize_view_opts args
          return def_opts unless opts.present?

          Card::Format.interpret_view_opts view, opts
          interpret_view_settings view, opts
          fail_on_invalid_opts! view, opts
          def_opts
        end

        def fail_on_invalid_opts! view, opts
          return unless opts.present?

          raise Card::Error::ServerError,
                "unknown view opts for #{view} view: #{opts}"
        end

        def normalize_view_opts args
          def_opts = {}
          def_opts[:alias_to] = args.shift if args[0].is_a?(Symbol)
          opts = args.shift || {}
          VIEW_DEFINITION_OPTS.each do |k|
            def_opts[k] ||= opts.delete k
          end
          [def_opts, opts]
        end

        def interpret_view_settings view, opts
          VIEW_SETTINGS.each do |setting_name|
            define_view_setting_method view, setting_name, opts.delete(setting_name)
          end
        end

        def define_view_setting_method view, setting_name, setting_value
          return unless setting_value

          method_name = Card::Format.view_setting_method_name view, setting_name
          define_method(method_name) { setting_value }
        end
      end
    end
  end
end

