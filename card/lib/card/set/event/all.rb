class Card
  module Set
    class Event
      module All
        def event_applies? event
          return unless set_condition_applies? event.set_module, event.opts[:changing]

          CONDITIONS.all? { |c| send "#{c}_condition_applies?", event, event.opts[c] }
        end

        # force skipping this event for all cards in act
        def skip_event! *events
          @full_skip_hash = nil
          force_events events, act_skip_hash
        end

        # force skipping this event for this card only
        def skip_event_in_action! *events
          force_events events, full_skip_hash
        end

        # force triggering this event (when it comes up) for all cards in act
        def trigger_event! *events
          @full_trigger_hash = nil
          force_events events, act_trigger_hash
        end

        # force triggering this event (when it comes up) for this card only
        def trigger_event_in_action! *events
          force_events events, full_trigger_hash
        end

        # hash form of raw skip setting, eg { "my_event" => true }
        def skip_hash
          @skip_hash ||= hash_with_value skip, true
        end

        def trigger_hash
          @trigger_hash ||= hash_with_value trigger, true
        end

        private

        def force_events events, hash
          events.each { |e| hash[e.to_s] = :force }
        end

        def set_condition_applies? set_module, old_sets
          return true if set_module == Card

          set_condition_card(old_sets).singleton_class.include? set_module
        end

        def on_condition_applies? _event, actions
          actions = Array(actions).compact
          actions.empty? ? true : actions.include?(action)
        end

        # if changing name/type, the old card has no-longer-applicable set modules, so we create
        # a new card to determine whether events apply.
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

        # "applies always means event can run
        # so if skip_condition_applies?, we do NOT skip
        def skip_condition_applies? event, allowed
          return true unless (val = full_skip_hash[event.name.to_s])

          allowed ? val.blank? : (val != :force)
        end

        def trigger_condition_applies? event, required
          return true unless required

          full_trigger_hash[event.name.to_s].present?
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

        def full_skip_hash
          @full_skip_hash ||= act_skip_hash.merge skip_in_action_hash
        end

        def act_skip_hash
          (act_card || self).skip_hash
        end

        def skip_in_action_hash
          hash_with_value skip_in_action, true
        end

        def full_trigger_hash
          @full_trigger_hash ||= act_trigger_hash.merge trigger_in_action_hash
        end

        def trigger_in_action_hash
          hash_with_value trigger_in_action, true
        end

        def act_trigger_hash
          (act_card || self).trigger_hash
        end

        def hash_with_value array, value
          Array.wrap(array).each_with_object({}) do |event, hash|
            hash[event.to_s] = value
          end
        end
      end
    end
  end
end
