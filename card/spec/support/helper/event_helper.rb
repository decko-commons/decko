class Card
  module SpecHelper
    module EventHelper
      # Make expectations in the event phase.
      # Takes a stage and registers the event_block in this stage as an event.
      # Unknown methods in the event_block are executed in the rspec context
      # instead of the card's context.
      # An additionally :trigger block in opts is expected that is called
      # to start the event phase.
      # You can restrict the event to a specific card by passing a name
      # with :for options.
      # That's for example necessary if you create a card in a event.
      # Otherwise you get a loop of card creations.
      # @example
      #   in_stage :initialize,
      #            for: "my test card",
      #            trigger: -> { test_card.update! content: '' } do
      #     expect(item_names).to eq []
      #   end
      def in_stage(stage, opts={}, &)
        Card.rspec_binding = binding
        trigger = opts.delete(:trigger)
        trigger = method(trigger) if trigger.is_a?(Symbol)
        add_test_event(stage, :in_stage_test, opts, &)
        ensure_clean_up stage do
          trigger.call
        end
      end

      def ensure_clean_up stage
        yield
      ensure
        remove_test_event stage, :in_stage_test
      end

      def create_with_event(name, stage, opts={}, &)
        in_stage(stage, opts.merge(for: name, trigger: -> { create name }), &)
      end

      # if you need more then one test event (otherwise use #in_stage)
      # @example
      #   with_test_events do
      #     test_event :store, for: "my card" do
      #        Card.create name: "other card"
      #     end
      #     test_event :finalize, for: "other card" do
      #        expect(content).to be_empty
      #     end
      #   end
      def with_test_events
        @events = []
        Card.rspec_binding = binding
        yield
      ensure
        @events.each do |stage, name|
          remove_test_event stage, name
        end
        Card.rspec_binding = false
      end

      def test_event(stage, opts={}, &)
        event_name = :"test_event#{@events.size}"
        @events << [stage, event_name]
        add_test_event(stage, event_name, opts, &)
      end

      def add_test_event(stage, name, opts={}, &)
        # use random set module that is always included so that the
        # event applies to all cards
        set_module = opts.delete(:set) || Card::Set::All::Type
        if (only_for_card = opts.delete(:for))
          opts[:when] = proc { |c| c.name == only_for_card }
        end
        Card::Set::Event.new(name, set_module).register(stage, opts, &)
      end

      def remove_test_event stage, name
        stage_sym = :"#{stage}_stage"
        Card.skip_callback stage_sym, :after, name
      end

      # Turn delayed jobs on and run jobs after the given block.
      # If count is given check if it matches the number of created jobs.
      def with_delayed_jobs count=nil
        delaying true, "did not start off empty"
        yield
        expect(Delayed::Job.count).to eq(count) if count
        Delayed::Worker.new.work_off
      ensure
        delaying false, "not all jobs were executed"
      end

      def delaying mode, error
        Cardio.delaying! mode
        expect(Delayed::Job.count).to eq(0), "expected empty jobs queue: #{error}"
      end
    end
  end
end
