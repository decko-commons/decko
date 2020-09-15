class Card
  module Set
    # Supports the definition of events via the {Api Events API}
    class Event
      # Events are the building blocks of the three transformative card actions: _create_,
      # _update_, and _delete_.
      #
      # (The fourth kind of action, _read_, does not transform cards, and is associated
      # with {Card::Format views}, not events).
      #
      # As described in detail in {Card::Director}, each act can have many actions, each
      # action has three phases, each phase has three stages, and each stage has many
      # events.
      #
      # Events are defined in set modules in {Card::Mod **mods**}. Learn more about
      # {Card::Mod set modules}.
      #
      # A simple event definition looks something like this:
      #
      #     event :append_you_know, :prepare_to_validate, on: :create do
      #       self.content = content + ", you know?"
      #     end
      #
      # Note:
      #
      # - `:append_you_know` is a unique event name.
      # - `:prepare_to_validate` is a {Card::Director stage}.
      # - `on: :create` specifies the action to which the event applies
      # - `self`, within the event card, is a card object.
      #
      # Any card within the {Card::Set set} on which this event is defined will
      # run this event during the `prepare_to_validate` stage when it is created.
      #
      # Events should not be defined within format blocks.
      module Api
        OPTIONS = {
          on: %i[create update delete save read],
          changed: Card::Dirty.dirty_options,
          changing: Card::Dirty.dirty_options,
          skip: [:allowed],
          trigger: [:required],
          when: nil
        }.freeze

        # Define an event for a set of cards.
        #
        # @param event [Symbol] unique event name
        # @param stage_or_opts [Symbol, Hash] if a Symbol, defines event's
        #   {Card::Director stage}. If a Hash, it's treated as the opts param.
        # @param opts [Hash] event options
        # @option opts [Symbol, Array] :on one or more actions in which the event
        #   should be executed. :save is shorthand for [:create, :update]. If no value
        #   is specified, event will fire on create, update, and delete.
        # @option opts [Symbol, Array] :changed fire event only if field has changed.
        #   valid values: name, content, db_content, type, type_id, left_id, right_id,
        #   codename, trash.
        # @option opts [Symbol, Array] :changing alias for :changed
        # @option opts [Symbol] :skip allow actions to skip this event.
        #   (eg. `skip: :allowed`)
        # @option opts [Symbol] :trigger allow actions to trigger this event
        #   explicitly. If `trigger: :required`, then event will not run unless explicitly
        #   triggered.
        # @option opts [Symbol, Proc] :when method (Symbol) or code (Proc) to execute
        #   to determine whether to fire event. Proc is given card as argument.
        # @option opts [Symbol] :before fire this event before the event specified.
        # @option opts [Symbol] :after fire this event after the event specified.
        # @option opts [Symbol] :around fire this event before the event specified. This
        #   event will receive a block and will need to call it for the specified
        #   event to fire.
        # @option opts [Symbol] :stage alternate representation for specifying stage
        # @option opts [True/False] :after_subcards run event after running subcard events
        def event event, stage_or_opts={}, opts={}, &final
          Event.new(event, stage_or_opts, opts, self, &final).register
        end
      end

      CONDITIONS = ::Set.new(Api::OPTIONS.keys).freeze

      include DelayedEvent
      include Options
      include Callbacks

      attr_reader :set_module, :opts

      def initialize event, stage_or_opts, opts, set_module, &final
        @event = event
        @set_module = set_module
        @opts = event_opts stage_or_opts, opts
        @event_block = final
      end

      def register
        validate_conditions
        Card.define_callbacks @event
        define_event
        set_event_callbacks
      end

      # @return the name of the event
      def name
        @event
      end

      def block
        @event_block
      end

      # the name for the method that only executes the code
      # defined in the event
      def simple_method_name
        "#{@event}_without_callbacks"
      end

      # the name for the method that adds the event to
      # the delayed job queue
      def delaying_method_name
        "#{@event}_with_delay"
      end

      private

      # EVENT DEFINITION

      def define_event
        define_simple_method
        define_event_method
      end

      def define_simple_method
        @set_module.class_exec(self) do |event|
          define_method event.simple_method_name, &event.block
        end
      end

      def define_event_method
        send "define_#{event_type}_event_method"
      end

      def event_type
        with_delay?(@opts) ? :delayed : :standard
      end

      def define_standard_event_method method_name=simple_method_name
        is_integration = @stage.to_s.match?(/integrate/)
        @set_module.class_exec(@event) do |event_name|
          define_method event_name do
            rescuing_if_integration is_integration do
              log_event_call event_name
              run_callbacks event_name do
                send method_name
              end
            end
          end
        end
      end
    end
  end

  def rescuing_if_integration is_integration
    is_integration ? rescuing_integration { yield } : yield
  end

  # one failed integration event should not harm others.
  def rescuing_integration
    yield
  rescue StandardError => e
    Card::Error.report e, self
  ensure
    true
  end

  def log_event_call event
    Rails.logger.debug "#{name}: #{event}"
    # puts "#{name}: #{event}"
    # puts "#{Card::Director.to_s}".green
  end
end
