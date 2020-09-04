RSpec.describe Card::Set::All::Subcards do
  let(:create_card) { Card.create!(name: "main card") }
  let(:create_card_with_subcards) do
    Card.create name: "main card",
                subcards: {
                  "11" => { subcards: { "111" => "A" } },
                  "12" => { subcards: { "121" => "A" } }
                }
  end

  describe "add subcards" do
    def save_transaction
      @trans = ActiveRecord::Base.connection.current_transaction
    end

    def record_names
      @trans.records.map(&:name)
    end

    after do
      @trans = nil
    end

    context "in integrate stage" do
      context "default subcard handling" do
        it "processes all cards in one transaction" do
          with_test_events do
            test_event :validate, on: :create, for: "main card" do
              save_transaction
              add_subcard("sub card")
            end

            test_event :finalize, on: :create, for: "main card" do
              expect(record_names).to eq ["main card", "sub card"]
            end

            create_card
          end
        end
      end

      context "with delayed jobs" do
        before { Delayed::Worker.delay_jobs = true }
        after { Delayed::Worker.delay_jobs = false }

        context "serial subcard handling" do
          class Card
            def __current_trans
              ActiveRecord::Base.connection.current_transaction
            end

            def __record_names trans=nil
              trans ||= __current_trans
              trans.records.map(&:name)
            end
          end

          it "processes subcards in separate transaction" do
            with_test_events do
              test_event :validate, on: :create, for: "main card" do
                sc = add_subcard("sub card")
                sc.director.delay!
              end

              test_event :finalize, on: :create, for: "main card" do
                expect(__record_names).to eq ["main card"]
                expect(subcard("sub card").director.stage).to eq nil
              end

              test_event :integrate, on: :create, for: "main card" do
                expect(__record_names).to eq []
                expect(subcard("sub card").director.stage).to eq nil
              end

              test_event :finalize, on: :create, for: "sub card" do
                expect(__record_names).to eq ["sub card"]
              end

              test_event :integrate_with_delay, on: :create do
                expect(__record_names).to eq []
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
              add_subcard("sub card")
            end

            test_event :finalize, on: :create, for: "main card" do
              save_transaction
            end

            main_card = create_card
            Delayed::Worker.new.work_off

            expect(record_names).to eq ["main card"]
            expect("sub card").to exist
            expect("sub create card").to exist

            act_of_main = main_card.acts.last
            expect(act_of_main).to eq Card["sub create card"].actions.last.act
            expect(act_of_main).to eq Card["sub card"].actions.last.act
          end
        end
      end
    end
  end
end
