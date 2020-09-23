# -*- encoding : utf-8 -*-

RSpec.describe Card::Env do
  describe "slot_opts" do
    it "allows only shark keys" do
      Card::Env.with_params slot: { bogus: "block", title: "captain" } do
        described_class.slot_opts == { title: "captain" }
      end
    end
  end

  describe "Env" do
    before { Delayed::Worker.delay_jobs = true }
    after { Delayed::Worker.delay_jobs = false }
    let(:create_card) { Card.create!(name: "main card") }

    it "survives to integration phase" do
      with_test_events do
        test_event :initialize, on: :create do
          Card::Env.root("new root")
        end
        test_event :integrate, on: :create do
          expect(Card::Env.root).to eq("new root")
        end
        test_event :integrate_with_delay, on: :create do
          expect(Card::Env.root).to eq("new root")
        end
        create_card
        Delayed::Worker.new.work_off
      end
    end
  end
end
