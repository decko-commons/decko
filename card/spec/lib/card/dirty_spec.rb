RSpec.describe Card::Dirty do
  describe "dirty attributes" do
    before { Delayed::Worker.delay_jobs = true }
    after { Delayed::Worker.delay_jobs = false }

    it "survives to integration phase" do
      with_test_events do
        test_event :validate do
          self.content = "new content"
        end
        test_event :integrate, for: "new name" do
          expect(name_is_changing?).to be_truthy
          expect(name_before_act).to eq("A")
          expect(db_content_before_act).to eq("Alpha [[Z]]")
        end
        test_event :integrate_with_delay, for: "new name" do
          expect(name_is_changing?).to be_truthy
          expect(name_before_act).to eq("A")
          expect(db_content_before_act).to eq("Alpha [[Z]]")
        end
        Card["A"].update! name: "new name"
        Delayed::Worker.new.work_off
      end
    end

    it '"changed" option works in integration phase' do
      @called_events = []
      def event_called ev
        @called_events << ev
      end

      with_test_events do
        test_event :integrate, changed: :name, for: "new name" do
          event_called :i_name
        end
        test_event :integrate, changed: :content do
          event_called :i_content
        end
        test_event :integrate_with_delay, changed: :name, for: "new name" do
          event_called :iwd_name
        end
        test_event :integrate_with_delay, changed: :content do
          event_called :iwd_content
        end
        Card["A"].update! name: "new name"
        Delayed::Worker.new.work_off
        expect(@called_events).to eq(%i[i_name iwd_name])
      end
    end
  end
end
