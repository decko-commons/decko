class Card
  module Set
    class Event
      # card methods for scheduling events and testing event applicability
      module All
        def schedule event
          @scheduled ||= {}
          return if @scheduled[event.to_sym]

          send :"#{event}_with_delay"
          @scheduled[event.to_sym] = true
        end

        include SkipAndTrigger

        def event_applies? event
          unless set_condition_applies? event.set_module, event.opts[:changing]
            return false
          end

          CONDITIONS.all? { |c| send "#{c}_condition_applies?", event, event.opts[c] }
        end

        private

        def set_condition_applies? set_module, old_sets
          return true if set_module == Card

          set_condition_card(old_sets).singleton_class.include? set_module
        end

        def on_condition_applies? _event, actions
          actions = Array(actions).compact
          actions.empty? ? true : actions.include?(action)
        end

        # if changing name/type, the old card has no-longer-applicable set modules,
        # so we create a new card to determine whether events apply.
        # (note: cached condition card would ideally be cleared after all
        # conditions are reviewed)
        # @param old_sets [True/False] whether to use the old_sets
        def set_condition_card old_sets
          return self if old_sets || no_current_action?

          @set_condition_card ||=
            updating_sets? ? set_condition_card_with_new_set_modules : self
        end

        # existing card is being changed in a way that alters its sets
        def updating_sets?
          action == :update && real? && (type_id_is_changing? || name_is_changing?)
        end

        # prevents locking in set_condition_card
        def no_current_action?
          return false if @current_action

          @set_condition_card = nil
          true
        end

        def set_condition_card_with_new_set_modules
          cc = Card.find id
          cc.name = name
          cc.type_id = type_id
          cc.include_set_modules
        end

        def changed_condition_applies? _event, db_columns
          return true unless action == :update

          db_columns = Array(db_columns).compact
          return true if db_columns.empty?

          db_columns.any? { |col| single_changed_condition_applies? col }
        end
        alias_method :changing_condition_applies?, :changed_condition_applies?

        def when_condition_applies? _event, block
          case block
          when Proc then block.call(self)
          when Symbol then send block
          else true
          end
        end

        def single_changed_condition_applies? db_column
          return true unless db_column

          send "#{db_column}_is_changing?"
        end

        def wrong_stage opts
          return false if director.stage_ok? opts

          if !stage
            "phase method #{method} called outside of event phases"
          else
            "#{opts.inspect} method #{method} called in stage #{stage}"
          end
        end

        def wrong_action actn
          return false if on_condition_applies?(nil, actn)

          "on: #{actn} method #{method} called on #{action}"
        end
      end
    end
  end
end
