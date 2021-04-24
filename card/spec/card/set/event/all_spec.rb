# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Event::All do
  let(:log) { @log ||= [] }
  let(:create_card) { Card.create!(name: "main card") }
  let :create_card_with_subcards do
    Card.create name: "main card",
                subcards: {
                  "11" => { subcards: { "111" => "A" } },
                  "12" => { subcards: { "121" => "A" } }
                }
  end

  def add_to_log entry
    log << entry
  end

  context "when restricted to changed content:" do
    STAGES = %i[validate store finalize integrate]

    def change_content
      Card["A"].update! content: "changed content"
    end

    it "is executed when content changed" do
      with_test_events do
        STAGES.each do |stage|
          test_event stage, on: :update, changed: :content, for: "A" do
            # can't access instance variables here but methods are fine
            add_to_log stage
          end
        end
        change_content
        expect(log).to contain_exactly(*STAGES)
      end
    end

    specify "content change is accessible in all stages" do
      with_test_events do
        STAGES.each do |stage|
          test_event stage, on: :update, changed: :content, for: "A" do
            add_to_log db_content_before_act
          end
        end
        content_before_change = [Card["A"].db_content] * STAGES.size
        change_content
        expect(log).to contain_exactly(*content_before_change)
      end
    end

    context "when changing type" do
      def update_type
        Card::Auth.as_bot do
          Card["Sample Pointer"].update! type: "Search"
        end
      end

      it "does NOT run update events from sets that no longer apply after change" do
        with_test_events do
          test_event :validate, on: :update, set: Card::Set::Type::Pointer do
            add_to_log "NO to run"
          end
          update_type
          expect(log).to be_empty
        end
      end

      it "does run update events from old sets when `changing` value present" do
        with_test_events do
          test_event :validate,
                     on: :update, set: Card::Set::Type::Pointer, changing: :type do
            add_to_log "YES to run"
          end
          update_type
          expect(log).to contain_exactly("YES to run")
        end
      end

      it "does run update events from sets that apply after change" do
        with_test_events do
          test_event :validate, on: :update, set: Card::Set::Type::SearchType do
            add_to_log "YES to run"
          end
          update_type
          expect(log).to contain_exactly("YES to run")
        end
      end

      # following does not yet work, because old card has both old sets and new sets
      # when conditions are tested.
      xit "does NOT run update events from new sets when `changing` value present" do
        with_test_events do
          test_event :validate,
                     on: :update, set: Card::Set::Type::SearchType, changing: :type do
            add_to_log "NO to run"
          end
          update_type
          expect(log).to be_empty
        end
      end
    end

    context "when changing name" do
      def update_name
        Card::Auth.as_bot do
          Card["Cardtype B+*type+*create"].update! name: "B+*update"
        end
      end

      it "does NOT run update events from sets that no longer apply after change" do
        with_test_events do
          test_event :validate, on: :update, set: Card::Set::Right::Create do
            add_to_log "NO to run"
          end
          update_name
          expect(log).to be_empty
        end
      end

      it "does run update events from old sets when `changing` value present" do
        with_test_events do
          test_event :validate,
                     on: :update, set: Card::Set::Right::Create, changing: :name do
            add_to_log "YES to run"
          end
          update_name
          expect(log).to contain_exactly("YES to run")
        end
      end

      it "does run update events from sets that apply after change" do
        with_test_events do
          test_event :validate, on: :update, set: Card::Set::Right::Update do
            add_to_log "YES to run"
          end
          update_name
          expect(log).to contain_exactly("YES to run")
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
            Card["A"].update! content: "changed content", trigger: :test_event_0
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
          skip_card.skip_event! :test_event_0
          skip_card.update! changes
        else
          skip_card.update! changes.merge(skip_key => :test_event_0)
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
end
