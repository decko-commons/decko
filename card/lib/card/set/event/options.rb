class Card
  module Set
    class Event
      module Options
        def validate_conditions
          @opts.each do |key, val|
            next if key.in? %i[stage before after around]

            validate_condition_name key
            validate_condition_value key, val
          end
        end

        def validate_condition_name condition
          return if CONDITIONS.include? condition

          raise ArgumentError,
                "invalid condition key '#{condition}' in event '#{@event}'\n" \
                "valid conditions are #{CONDITIONS.to_a.join ', '}"
        end

        def validate_condition_value condition, val
          if condition == :when
            validate_when_value val
          else
            invalid = Array.wrap(val) - Api::OPTIONS[condition]
            return if invalid.empty?

            raise ArgumentError,
                  "invalid option#{'s' if invalid.size > 1} '#{invalid}' "\
                  "for condition '#{condition}' in event '#{@event}'"
          end
        end

        def validate_when_value val
          return if val.is_a?(Symbol) || val.is_a?(Proc)

          raise ArgumentError,
                "invalid value for condition 'when' in event '#{@event}'\n" \
                "must be a symbol or a proc"
        end

        def event_opts stage_or_opts, opts
          opts = normalize_opts stage_or_opts, opts
          process_stage_opts opts
          process_action_opts opts
          process_delayed_job_opts opts
          opts
        end

        def normalize_opts stage_or_opts, opts
          if stage_or_opts.is_a? Symbol
            opts[:stage] = stage_or_opts
          else
            opts = stage_or_opts
          end
          opts
        end

        def process_action_opts opts
          opts[:on] = %i[create update] if opts[:on] == :save
        end

        def process_stage_opts opts
          stage = opts.delete :stage
          after_subcards = opts.delete :after_subcards
          return if opts[:after] || opts[:before] || opts[:around] || !(@stage = stage)
          # after, before, or around will override stage configuration

          opts[:after] = callback_name stage, after_subcards
        end

        def callback_name stage, after_subcards=false
          name = after_subcards ? "#{stage}_final_stage" : "#{stage}_stage"
          name.to_sym
        end
      end
    end
  end
end
