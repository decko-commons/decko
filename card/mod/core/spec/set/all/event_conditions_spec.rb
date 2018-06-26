# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::EventConditions do
  let(:create_card) {Card.create!(name: "main card")}
  let(:create_card_with_subcards) do
    Card.create name: "main card",
                subcards: {
                  "11" => { subcards: { "111" => "A" } },
                  "12" => { subcards: { "121" => "A" } }
                }
  end

  context "restricted to changed content:" do
    STAGES = [:validate, :store, :finalize, :integrate]

    def add_to_log entry
      @log << entry
    end

    def change_content
      Card["A"].update_attributes! content: "changed content"
    end

    before do
      @log = []
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
        expect(@log).to contain_exactly(*STAGES)
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
        expect(@log).to contain_exactly(*content_before_change)
      end
    end

    specify "skip_event condition" do
      with_test_events do
        test_event :validate, on: :update, optional: true, for: "A" do
          add_to_log "not skipped"
        end
        Card["A"].update_attributes! content: "changed content", skip_event: :test_event_0

        aggregate_failures do
          expect(@log).to be_empty
          Card["A"].update_attributes! content: "changed content"
          expect(@log).to contain_exactly "not skipped"
        end
      end
    end

    specify "skip_event condition in subcard" do
      with_test_events do
        test_event :validate, on: :update, optional: true, for: "A+B" do
          add_to_log "not skipped"
        end
        Card["A"].update_attributes! content: "changed content",
                                     skip_event: :test_event_0,
                                     subcards: { "+B" => "changed +B content" }

        aggregate_failures do
          expect(@log).to be_empty
          Card["A"].update_attributes! content: "changed content",
                                       subcards: { "+B" => "changed +B content" }
          expect(@log).to contain_exactly "not skipped"
        end
      end
    end

    specify "skip_event_in_action condition" do
      with_test_events do
        test_event :validate, on: :update, optional: true do
          add_to_log "#{name} not skipped"
        end
        Card["A"].update_attributes! content: "changed content",
                                     skip_event_in_action: :test_event_0,
                                     subcards: { "+B" => "changed +B content" }

        aggregate_failures do
          expect(@log).to contain_exactly "A+B not skipped"
          Card["A"].update_attributes! content: "changed content",
                                       subcards: { "+B" => "changed +B content" }
          expect(@log).to contain_exactly "A+B not skipped",
                                          "A not skipped",
                                          "A+B not skipped"
        end
      end
    end
  end
end
