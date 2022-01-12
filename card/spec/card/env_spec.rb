# -*- encoding : utf-8 -*-

RSpec.describe Card::Env do
  describe "slot_opts" do
    it "allows only shark keys" do
      described_class.with_params slot: { bogus: "block", title: "captain" } do
        expect(described_class.slot_opts).to eq(title: "captain")
      end
    end
  end

  describe "Env" do
    before { Cardio.delaying! }

    after { Cardio.delaying! :off }

    let(:create_card) { Card.create!(name: "main card") }

    it "survives to integration phase" do
      with_test_events do
        test_event :initialize, on: :create do
          described_class.main_name = "new root"
        end
        test_event :integrate, on: :create do
          expect(described_class.main_name).to eq("new root")
        end
        test_event :integrate_with_delay, on: :create do
          expect(described_class.main_name).to eq("new root")
        end
        create_card
        Delayed::Worker.new.work_off
      end
    end
  end
end
