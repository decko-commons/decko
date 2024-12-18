class Card
  module Set
    module Format
      module AbstractFormat
        # handles processing of view definition options
        # (not to be confused with view rendering options. For that, see
        # {Card::View::Options})
        module ViewOpts
          # The unknown_ok tag is a global tag for a view and should be used only in
          # contexts when a Format object is not available. If a format is available,
          # a format-specific value can be retrieved using view settings.
          mattr_accessor :unknown_ok
          self.unknown_ok = {}

          # view setting values can be accessed from Format objects (eg within format
          # blocks in set modules) using #view_setting(:setting_name, :view_name)
          VIEW_SETTINGS = %i[cache compact denial perms unknown wrap expire].freeze

          # view def opts are used in defining views but are not available
          # at any later point
          VIEW_DEF_OPTS = %i[alias_to mod template async].freeze

          private

          def process_view_opts view, args
            def_opts, opts = normalize_view_opts args
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
            VIEW_DEF_OPTS.each do |k|
              def_opts[k] ||= opts.delete k
            end
            [def_opts, opts]
          end

          def interpret_view_settings view, opts
            return unless opts.present?

            unknown_ok[view] = true if opts[:unknown] == true

            VIEW_SETTINGS.each do |setting_name|
              define_view_setting_method view, setting_name, opts.delete(setting_name)
            end
          end

          def define_view_setting_method view, setting_name, setting_value
            return unless setting_value

            method_name = Card::Set::Format.view_setting_method_name view, setting_name
            define_method(method_name) { setting_value }
          end
        end
      end
    end
  end
end
