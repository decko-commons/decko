# -*- encoding : utf-8 -*-

# spec doesn't run when describing Card::Director as constant
RSpec.describe "Card::Director" do
  STAGE_MAP = { VI: :initialize,
                VP: :prepare_to_validate,
                VV: :validate,
                SP: :prepare_to_store,
                SS: :store,
                SF: :finalize,
                II: :integrate,
                IA: :after_integrate,
                ID: :integrate_with_delay }.freeze

  describe "abortion" do
    let(:create_card) { Card.create name: "a card" }
    let(:create_card_with_subcard) do
      Card.create name: "a card", subcards: { "a subcard" => "content" }
    end

    subject { Card.fetch "a card" }

    context "when error added" do
      it "stops act in validation phase" do
        in_stage :validate, on: :save, trigger: -> { create_card } do
          errors.add :stop, "don't do this"
        end
        is_expected.to be_falsey
      end

      it "stops act in storage phase" do
        in_stage :store, on: :save, trigger: -> { create_card } do
          errors.add :stop, "don't do this"
        end
        is_expected.to be_falsey
      end
    end

    context "when exception raised" do
      it "rollbacks in finalize stage" do
        begin
          in_stage :finalize, on: :save, trigger: -> { create_card } do
            raise Card::Error, "rollback"
          end
        rescue Card::Error => e
        ensure
          is_expected.to be_falsey
        end
      end

      it "does not rollback in integrate stage" do
        begin
          Card::Auth.as_bot do
            in_stage :integrate, on: :save, trigger: -> { create_card } do
              raise Card::Error::Abort, "rollback"
            end
          end
        rescue Card::Error::Abort => e
        ensure
          is_expected.to be_truthy
        end
      end
    end

    context "when abort :success called" do
      it "aborts storage in validation stage" do
        in_stage :validate, on: :create, trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_falsey
      end

      it "does not execute subcard stages on create" do
        @called_events = []

        def event_called ev
          @called_events << ev
        end

        with_test_events do
          test_event :validate, on: :create, for: "a card" do
            abort :success
          end

          STAGE_MAP.each do |stage_shortname, stage|
            test_event stage, on: :create, for: "a subcard" do
              event_called stage_shortname
            end
          end

          create_card_with_subcard
          expect(@called_events).to eq %i[VI VP]
        end
      end

      it "does not delete children" do
        @called_events = []

        def event_called ev
          @called_events << ev
        end

        with_test_events do
          test_event :validate, on: :delete, for: "A" do
            abort :success
          end
          STAGE_MAP.each do |stage_shortname, stage|
            test_event stage, on: :delete, for: "A+B" do
              event_called stage_shortname
            end
          end
          Card["A"].delete!
          expect(@called_events).to eq []
        end
      end

      it "aborts storage in store stage" do
        in_stage :store, on: :create, trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_falsey
      end

      it "does not abort storage in finalize stage" do
        in_stage :finalize, on: :create, trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_truthy
      end

      it "does not abort storage in integrate stage" do
        in_stage :integrate, on: :create, trigger: -> { create_card } do
          abort :success
        end
        is_expected.to be_truthy
      end
    end
  end

  describe "stage order" do
    let :create_card_with_subcards do
      Card.create name: "1", subcards: { "11" => { subcards: { "111" => "A" } },
                                         "12" => { subcards: { "121" => "A" } } }
    end

    let :create_card_with_junction do
      Card.create name: "1+2", subcards: { "11" => "A" }
    end

    let(:preorder) { %w[1 11 111 12 121] }

    describe "validate" do
      it "is pre-order depth-first" do
        order = []
        in_stage :validate, on: :create,
                            trigger: -> { create_card_with_subcards } do
          order << name
        end
        expect(order).to eq(preorder)
      end

      it "executes all validate stages before next stage" do
        order = []
        with_test_events do
          test_event :validate, on: :create do
            order << "V:#{name}"
          end
          test_event :prepare_to_store, on: :create do
            order << "S:#{name}"
          end
          create_card_with_subcards
        end
        expect(order)
          .to eq(%w[V:1 V:11 V:111 V:12 V:121
                    S:1 S:11 S:111 S:12 S:121])
      end
    end

    describe "finalize" do
      it "is pre-order depth-first" do
        order = []
        in_stage :finalize, on: :create, trigger: -> { create_card_with_subcards } do
          order << name
        end
        expect(order).to eq(preorder)
      end
    end

    describe "store" do
      it "is pre-order depth-first" do
        order = []
        in_stage :store, on: :create, trigger: -> { create_card_with_subcards } do
          order << name
        end
        expect(order).to eq(preorder)
      end
    end

    describe "store and finalize" do
      it "executes finalize when all subcards are stored" do
        order = []
        with_test_events do
          test_event :store, on: :create do
            order << "S:#{name}"
          end
          test_event :finalize, on: :create do
            order << "F:#{name}"
          end
          create_card_with_subcards
        end
        expect(order)
          .to eq(%w[S:1 S:11 S:111 S:12 S:121
                    F:1 F:11 F:111 F:12 F:121])
      end
    end

    describe "complete run" do
      def with_complete_events adding_subcard: false
        order = []
        with_test_events do
          define_test_events adding_subcard, order
          yield
        end
        order
      end

      def define_test_events adding_subcard, order
        STAGE_MAP.each do |stage_shortname, stage|
          test_event stage, on: :create do
            order << "#{stage_shortname}:#{name}"
            add_subcard "112v" if adding_subcard && stage == :validate && name == "11"
          end
        end
      end

      it "is in correct order" do
        order = with_complete_events adding_subcard: true do
          create_card_with_subcards
        end
        # Delayed::Worker.new.work_off
        expect(order).to eq(%w[VI:1 VI:11 VI:111 VI:12 VI:121
                               VP:1 VP:11 VP:111 VP:12 VP:121
                               VV:1 VV:11 VV:111
                               VI:112v
                               VP:112v
                               VV:112v VV:12 VV:121
                               SP:1 SP:11 SP:111 SP:112v SP:12 SP:121
                               SS:1 SS:11 SS:111 SS:112v SS:12 SS:121
                               SF:1 SF:11 SF:111 SF:112v SF:12 SF:121
                               II:1 II:11 II:111 II:112v II:12 II:121
                               IA:1 IA:11 IA:111 IA:112v IA:12 IA:121
                               ID:1 ID:11 ID:111 ID:112v ID:12 ID:121])
      end

      it "with junction" do
        order = with_complete_events do
          create_card_with_junction
        end
        # Delayed::Worker.new.work_off
        expect(order).to eq(%w[VI:1+2 VI:11
                               VP:1+2 VP:11
                               VV:1+2 VV:11
                               SP:1+2 SP:11
                               SS:1+2
                               VI:1 VP:1 VV:1 SP:1 SS:1
                               VI:2 VP:2 VV:2 SP:2 SS:2
                               SS:11
                               SF:1+2 SF:11 SF:1 SF:2
                               II:1+2 II:11 II:1 II:2
                               IA:1+2 IA:11 IA:1 IA:2
                               ID:1+2 ID:11 ID:1 ID:2])
      end
    end
  end

  example "dirty checks work in intergration stage" do
    executed = false
    in_stage :integrate, on: :create,
                         when: proc { |c| c.db_content_changed? },
                         trigger: -> { create "changed content" } do
      executed = true
    end
    expect(executed).to be_truthy
  end

  describe "subcards" do
    def create_subcards
      Card.create! name: "", subcards: {
        "+sub1" => "some content",
        "+sub2" => { "+sub3" => "content" }
      }
    end

    def create_single_card
      Card.create! name: "single card"
    end

    it "has correct name if supercard name get changed" do
      Card::Auth.as_bot do
        changed = false
        in_stage :prepare_to_validate, on: :create, trigger: :create_subcards do
          self.name = "main" if name.empty? && !changed
        end
        expect(Card["main+sub1"].class).to eq(Card)
        expect(Card["main+sub2+sub3"].class).to eq(Card)
      end
    end

    it "has correct name if supercard's name get changed to a junction card" do
      Card::Auth.as_bot do
        changed = false
        in_stage :prepare_to_validate,
                 on: :create,
                 trigger: :create_subcards do
          if name.empty? && !changed
            self.name = "main1+main2"
            expect(subfield("sub1")).to be
            expect(subfield("sub1").content).to eq("some content")
          end
        end
        expect(Card["main1+main2+sub1"].class).to eq(Card)
        expect(Card["main1+main2+sub1"].content).to eq("some content")
        expect(Card["main1+main2+sub2+sub3"].class).to eq(Card)
        expect(Card["main1+main2+sub2+sub3"].content).to eq("content")
      end
    end

    it "load type_plus_right set module" do
      Card::Auth.as_bot do
        in_stage :prepare_to_validate,
                 on: :create,
                 for: "single card",
                 trigger: :create_single_card do

          u_card = attach_subfield "a user", type_id: Card::UserID
          f_card = u_card.attach_subfield "*follow"
          expect(f_card.set_modules)
            .to include(Card::Set::TypePlusRight::User::Follow)
        end
      end
    end

    it "adds subsubcard to correct subdirector" do
      Card::Auth.as_bot do
        in_stage :prepare_to_store,
                 on: :create,
                 trigger: -> { Card.create! name: "main" } do
          case name
          when "main"
            add_subcard "subby", "+sub2" => {
              subcards: { "AARGH" => { "+sub4" => "more content" } }
            }
            in_subdirectors = director.subdirectors.any? do |subdir|
              subdir.card.name == "AARGH"
            end
            expect(in_subdirectors).to be_falsey
          when "subby+sub2"
            in_subsubdirectors = director.subdirectors.any? do |subdir|
              subdir.card.name == "AARGH"
            end
            expect(in_subsubdirectors).to be_truthy
          end
        end
      end
    end

    xit "executes integrate phase when act card didn't change" do
        @called_events = []

        def event_called ev
          @called_events << ev
        end

        with_test_events do
          test_event :validate, on: :update, for: "A" do
            event_called "v"
            abort :success
          end
          test_event :integrate, on: :update do
            event_called "i"
          end
          Card["A"].update! subcards: { "+B" => "new content" }
          expect(@called_events).to eq ["i"]
        end
    end
  end

  describe "creating and updating cards in stages" do
    it "update works in integrate stage" do
      act_cnt = Card["A"].acts.size
      in_stage :integrate,
               on: :create,
               trigger: -> { Card.create! name: "act card" } do
        Card["A"].update content: "changed content"
      end
      expect(Card["A"].content).to eq "changed content"
      expect(Card["A"].acts.size).to eq(act_cnt), "no act added to A"
      expect(Card["act card"].acts.size).to eq(1), "new act for 'act card'"
      expect(Card["A"].actions.last.act).to eq Card["act card"].acts.last
    end

    it "update works integrate_with_delay stage" do
      act_cnt = Card["A"].acts.size
      with_delayed_jobs 1 do
        in_stage :integrate_with_delay,
                 on: :create, for: "act card",
                 trigger: -> { Card.create! name: "act card" } do
          Card["A"].update content: "changed content"
        end
      end
      expect(Card["A"].content).to eq "changed content"
      expect(Card["A"].acts.size).to eq(act_cnt), "expected no new act on A"
      expect(Card["act card"].acts.size).to eq(1), "new act for 'act card'"
      expect(Card["A"].actions.last.act).to eq Card["act card"].acts.last

      Delayed::Worker.delay_jobs = false
    end

    it "create works in integrate_with_delay stage" do
      with_delayed_jobs 1 do
        in_stage :integrate_with_delay,
                 on: :create, for: "act card",
                 trigger: -> { Card.create! name: "act card" } do
          Card.create! name: "iwd created card", content: "new content"
        end
      end
      expect(Card["iwd created card"]).to exist.and have_db_content "new content"
      expect(Card["act card"].acts.size).to eq(1), "new act for 'act card'"
      expect(Card["iwd created card"].actions.last.act).to eq Card["act card"].acts.last
      expect(Card["iwd created card"].acts.size).to eq(0), "no act added"
    end
  end
end
