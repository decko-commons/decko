# -*- encoding : utf-8 -*-

STAGES = %i[validate store finalize integrate].freeze

RSpec.describe Card::Set::Event::All do
  let(:log) { @log ||= [] }
  let(:create_card) { Card.create!(name: "main card") }
  let :create_card_with_subcards do
    Card.create name: "main card",
                subcards: { "11" => { subcards: { "111" => "A" } },
                            "12" => { subcards: { "121" => "A" } } }
  end

  def add_to_log entry
    log << entry
  end

  def log_validation args
    test_event :validate, args.merge(on: :update) do
      add_to_log "VALIDATION RAN"
    end
  end

  context "when changing content" do
    def change_content
      Card["A"].update! content: "changed content"
    end

    def in_each_stage
      STAGES.each do |stage|
        test_event stage, on: :update, changed: :content, for: "A" do
          yield stage: stage, content_changed: db_content_before_act
        end
      end
    end

    def log_at_each_stage key
      with_test_events do
        in_each_stage { |hash| add_to_log hash[key] }
        change_content
      end
    end

    it "is executed when content changed" do
      log_at_each_stage :stage
      expect(log).to contain_exactly(*STAGES)
    end

    specify "content change is accessible in all stages" do
      expected_content = [Card["A"].db_content] * STAGES.size
      log_at_each_stage :content_changed
      expect(log).to contain_exactly(*expected_content)
    end
  end

  context "when changing type" do
    def update_type
      update_card "Sample Pointer", type: "Search"
    end

    def update_type_with_event args
      with_test_events do
        log_validation args
        update_type
      end
    end

    # events are on pointer (the FROM type)
    context "when event is on OLD type's set" do
      it "DOES run with `changing: :type`" do
        update_type_with_event set: Card::Set::Type::Pointer, changing: :type
        expect(log).to contain_exactly("VALIDATION RAN")
      end

      it "does NOT run by default" do
        update_type_with_event set: Card::Set::Type::Pointer
        expect(log).to be_empty
      end
    end

    # events are on search (the TO type)
    context "when event is on NEW type's set" do
      # following does not yet work, because old card has both old sets and new sets
      # when conditions are tested.
      xit "does NOT run with `changing: :type`" do
        update_type_with_event set: Card::Set::Type::SearchType, changing: :type
        expect(log).to be_empty
      end

      it "DOES run by default" do
        update_type_with_event set: Card::Set::Type::SearchType
        expect(log).to contain_exactly("VALIDATION RAN")
      end
    end
  end

  context "when changing name" do
    def update_name_with_event args
      with_test_events do
        log_validation args
        update_name
      end
    end

    def update_name
      update_card "Cardtype B+*type+*create", name: "B+*update"
    end

    # events are on +*create (the FROM name)
    context "when event is on OLD type's set" do
      it "does NOT run by default" do
        update_name_with_event set: Card::Set::Right::Create
        expect(log).to be_empty
      end

      it "DOES run with `changing: :name" do
        update_name_with_event set: Card::Set::Right::Create, changing: :name
        expect(log).to contain_exactly("VALIDATION RAN")
      end
    end

    # events are on +*update (the TO name)
    context "when event is on NEW names's set" do
      it "DOES run by default" do
        update_name_with_event set: Card::Set::Right::Update
        expect(log).to contain_exactly("VALIDATION RAN")
      end

      # following does not yet work, because old card has both old sets and new sets
      # when conditions are tested.
      xit "does NOT run with `changing: :name`" do
        update_name_with_event set: Card::Set::Right::Update, changing: :name
        expect(log).to be_empty
      end
    end
  end

  describe "trigger option" do
    specify "trigger for whole act" do
      with_test_events do
        test_event :validate, on: :update, trigger: :required, for: "A" do
          add_to_log "triggered"
        end
        Card["A"].update! content: "changed content"

        aggregate_failures do
          expect(log).to be_empty
          Card["A"].update! content: "changed content", trigger: :test_event0
          expect(log).to contain_exactly "triggered"
        end
      end
    end
  end

  describe "skip option" do
    def expect_skipping changes, log1, log2,
                        for_name: nil, skip_key: :skip, allowed: :allowed, force: false
      with_test_events do
        add_logging_test_event allowed, for_name
        update_with_skip force, changes, skip_key

        aggregate_failures do
          expect(log).to eq(log1)                              # logging with skip
          Card["A"].update! changes                             # update without skip
          expect(log).to contain_exactly(*log2)                # logging without skip
        end
      end
    end

    def add_logging_test_event allowed, for_name
      event_args = { on: :update, skip: allowed }
      event_args[:for] = for_name if for_name
      test_event(:validate, event_args) do
        add_to_log "#{name} executed"
      end
    end

    def update_with_skip force, changes, skip_key
      skip_card = Card["A"]
      if force
        skip_card.skip_event! :test_event0
        skip_card.update! changes
      else
        skip_card.update! changes.merge(skip_key => :test_event0)
      end
    end

    specify "skip condition" do
      expect_skipping({ content: "changed" }, [], "A executed", for_name: "A")
    end

    specify "skip condition in subcard" do
      expect_skipping({ content: "changed", subcards: { "+B" => "changed +B" } },
                      [], "A+B executed", for_name: "A+B")
    end

    specify "skip_in_action condition" do
      expect_skipping({ content: "changed", subcards: { "+B" => "changed +B" } },
                      ["A+B executed"],
                      ["A executed", "A+B executed", "A+B executed"],
                      skip_key: :skip_in_action)
    end

    specify "force skip" do
      expect_skipping({ content: "changed" }, [], "A executed",
                      force: true, for_name: "A")
    end
  end
end
