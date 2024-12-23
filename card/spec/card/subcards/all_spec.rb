RSpec.describe Card::Subcards::All do
  let(:create_card) { Card.create!(name: "main card") }
  let(:create_card_with_subcards) do
    Card.create name: "main card",
                subcards: { "11" => { subcards: { "111" => "A" } },
                            "12" => { subcards: { "121" => "A" } } }
  end

  Card.class_eval do
    def __current_trans
      @current_trans = ActiveRecord::Base.connection.current_transaction
    end

    def __record_names reset=false
      trans = @current_trans && !reset ? @current_trans : __current_trans
      trans.records&.map { |r| r.try :name }&.compact
    end
  end

  describe "add subcards" do
    context "when in integrate stage" do
      context "with default subcard handling" do
        it "processes all cards in one transaction" do
          with_test_events do
            test_event :validate, on: :create, for: "main card" do
              subcard("sub card")
            end

            test_event :finalize, on: :create, for: "main card" do
              expect(__record_names).to eq ["main card", "sub card"]
            end

            create_card
          end
        end
      end

      context "with delayed jobs" do
        before { Cardio.delaying! }

        after { Cardio.delaying! :off }

        context "with serial subcard handling" do
          it "director.delay! processes subcards in separate transaction" do
            with_test_events do
              test_event :validate, on: :create, for: "main card" do
                subcard("sub card").director.delay!
              end

              test_event :finalize, on: :create, for: "main card" do
                expect(__record_names(true)).to eq ["main card"]
                expect(subcard("sub card").director.current_stage_index).to eq nil
              end

              test_event :integrate, on: :create, for: "main card" do
                expect(__record_names(true)).to eq(nil)
                expect(subcard("sub card").director.current_stage_index).to eq nil
              end

              test_event :finalize, on: :create, for: "sub card" do
                expect(__record_names(true)).to eq ["sub card"]
              end

              test_event :integrate_with_delay, on: :create do
                expect(__record_names(true)).to eq(nil)
              end
              create_card
              expect(Delayed::Worker.new.work_off).to eq [2, 0]
              expect(Card["sub card"]).to be_instance_of(Card)
            end
          end
        end
      end

      describe "in integrate_with_delay stage" do
        it "processes cards not in the same transaction" do
          with_test_events do
            test_event :integrate_with_delay, on: :create, for: "main card" do
              Card.create! name: "sub create card"
              subcard "sub card"
            end

            test_event :finalize, on: :create, for: "main card" do
              __current_trans
            end

            main_card = create_card
            Delayed::Worker.new.work_off

            expect(main_card.__record_names).to eq ["main card"]
            expect(Card["sub card"]).to exist
            expect(Card["sub create card"]).to exist

            act_of_main = main_card.acts.last
            expect(act_of_main).to eq Card["sub create card"].actions.last.act
            expect(act_of_main).to eq Card["sub card"].actions.last.act
          end
        end
      end
    end
  end
end
