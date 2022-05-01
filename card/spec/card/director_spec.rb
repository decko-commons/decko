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

  let(:called_events) { @called_events ||= [] }

  def stage_test_events args
    STAGE_MAP.each do |stage_shortname, stage|
      test_event(stage, args) { called_events << stage_shortname }
    end
  end

  def stop_at_stage stage
    in_stage stage, on: :save, trigger: -> { create_card } do
      errors.add :stop, "don't do this"
    end
  end

  def success_at_stage stage
    in_stage(stage, on: :create, trigger: -> { create_card }) { abort :success }
  end

  describe "abortion" do
    subject { Card.fetch "a card" }

    let(:create_card) { Card.create name: "a card" }
    let(:create_card_with_subcard) do
      Card.create name: "a card", subcards: { "a subcard" => "content" }
    end

    context "when error added" do
      it "stops act in validation phase" do
        stop_at_stage :validate
        is_expected.to be_falsey
      end

      it "stops act in storage phase" do
        stop_at_stage :store
        is_expected.to be_falsey
      end
    end

    context "when exception raised" do
      def rollback_at_stage stage
        in_stage stage, on: :save, trigger: -> { create_card } do
          raise Card::Error, "rollback"
        end
      rescue Card::Error
      end

      it "rollbacks in finalize stage" do
        rollback_at_stage :finalize
        is_expected.to be_falsey
      end

      it "does not rollback in integrate stage", is_bot: true do
        rollback_at_stage :integrate
        is_expected.to be_truthy
      end
    end

    context "when abort :success called" do
      it "aborts storage in validation stage" do
        success_at_stage :validate
        is_expected.to be_falsey
      end

      it "does not execute subcard stages on create" do
        with_test_events do
          test_event(:validate, on: :create, for: "a card") { abort :success }
          stage_test_events on: :create, for: "a subcard"

          create_card_with_subcard
          expect(called_events).to eq %i[VI VP]
        end
      end

      it "does not delete children" do
        with_test_events do
          test_event(:validate, on: :delete, for: "A") { abort :success }
          stage_test_events on: :delete, for: "A+B"
          Card["A"].delete!
          expect(called_events).to eq []
        end
      end

      it "aborts storage in store stage" do
        success_at_stage :store
        is_expected.to be_falsey
      end

      it "does not abort storage in finalize stage" do
        success_at_stage :finalize
        is_expected.to be_truthy
      end

      it "does not abort storage in integrate stage" do
        success_at_stage :integrate
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

    def expect_subcards_first order, hash={}
      with_test_events do
        hash.each do |stage, prefix|
          test_event(stage, on: :create) { called_events << "#{prefix}:#{name}" }
        end
        create_card_with_subcards
      end
      expect(called_events).to eq(order)
    end

    describe "validate" do
      it "is pre-order depth-first" do
        in_stage :validate, on: :create, trigger: -> { create_card_with_subcards } do
          called_events << name
        end
        expect(called_events).to eq(preorder)
      end

      it "finishes all validate stages before next stage" do
        expect_subcards_first %w[V:1 V:11 V:111 V:12 V:121
                                 S:1 S:11 S:111 S:12 S:121],
                              validate: "V", prepare_to_store: "S"
      end
    end

    describe "store and finalize" do
      it "executes finalize when all subcards are stored" do
        expect_subcards_first %w[S:1 S:11 S:111 S:12 S:121
                                 F:1 F:11 F:111 F:12 F:121],
                              store: "S", finalize: "F"
      end
    end

    %i[finalize store].each do |stage|
      describe "finalize" do
        it "is pre-order depth-first" do
          in_stage stage, on: :create, trigger: -> { create_card_with_subcards } do
            called_events << name
          end
          expect(called_events).to eq(preorder)
        end
      end
    end

    describe "complete run" do
      def with_complete_events adding_subcard: false
        with_test_events do
          define_test_events adding_subcard, called_events
          yield
        end
      end

      def define_test_events adding_subcard, called_events
        STAGE_MAP.each do |stage_shortname, stage|
          subcard = adding_subcard && stage == :validate
          define_test_event stage, subcard do |name|
            called_events << "#{stage_shortname}:#{name}"
          end
        end
      end

      def define_test_event stage, subcard
        test_event stage, on: :create do
          yield name
          subcard "112v" if subcard && name == "11"
        end
      end

      it "is in correct order" do
        with_complete_events(adding_subcard: true) { create_card_with_subcards }
        # Delayed::Worker.new.work_off
        expect(called_events).to eq(%w[VI:1 VI:11 VI:111 VI:12 VI:121
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
        with_complete_events { create_card_with_junction }
        # Delayed::Worker.new.work_off
        expect(called_events).to eq(%w[VI:1+2 VI:11
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
      Card.create! name: "", subcards: { "+sub1" => "some content",
                                         "+sub2" => { "+sub3" => "content" } }
    end

    def create_single_card
      Card.create! name: "single card"
    end

    it "has correct name if supercard name get changed", as_bot: true do
      changed = false
      in_stage :prepare_to_validate, on: :create, trigger: :create_subcards do
        self.name = "main" if name.empty? && !changed
      end
      expect(Card["main+sub1"].class).to eq(Card)
      expect(Card["main+sub2+sub3"].class).to eq(Card)
    end

    it "has correct name if supercard's name gets changed to a junction", as_bot: true do
      changed = false
      in_stage :prepare_to_validate, on: :create, trigger: :create_subcards do
        if name.empty? && !changed
          self.name = "main1+main2"
          expect(field("sub1")).to be
          expect(field("sub1").content).to eq("some content")
        end
      end
      expect(Card["main1+main2+sub1"].class).to eq(Card)
      expect(Card["main1+main2+sub1"].content).to eq("some content")
      expect(Card["main1+main2+sub2+sub3"].class).to eq(Card)
      expect(Card["main1+main2+sub2+sub3"].content).to eq("content")
    end

    it "load type_plus_right set module", as_bot: true do
      in_stage :prepare_to_validate, on: :create, for: "single card",
                                     trigger: :create_single_card do
        u_card = field "a user", type_id: Card::UserID
        f_card = u_card.field "*follow"
        expect(f_card.set_modules).to include(Card::Set::TypePlusRight::User::Follow)
      end
    end

    def sub? director
      director.subdirectors.any? { |subdir| subdir.card.name == "AARGH" }
    end

    it "adds subsubcard to correct subdirector", as_bot: true do
      test = self
      in_stage :prepare_to_store, on: :create,
                                  trigger: -> { Card.create! name: "main" } do
        case name
        when "main"
          subcard "subby", "+sub2" => { subcards: { "AARGH" => { "+sub4" => "hi" } } }
          expect(test).not_to be_sub(director)
        when "subby+sub2"
          expect(test).to be_sub(director)
        end
      end
    end

    it "executes integrate phase when act card didn't change" do
      with_test_events do
        test_event(:integrate, on: :update) { called_events << "i" }
        Card["A"].update! subcards: { "+B" => "new content" }
        expect(called_events).to eq(%w[i i])
      end
    end
  end

  describe "creating and updating cards in stages" do
    it "update works in integrate stage" do
      act_cnt = Card["A"].acts.size
      in_stage :integrate, on: :create,
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
        in_stage :integrate_with_delay, on: :create, for: "act card",
                                        trigger: -> { Card.create! name: "act card" } do
          Card["A"].update content: "changed content"
        end
      end
      expect(Card["A"].content).to eq "changed content"
      expect(Card["A"].acts.size).to eq(act_cnt), "expected no new act on A"
      expect(Card["act card"].acts.size).to eq(1), "new act for 'act card'"
      expect(Card["A"].actions.last.act).to eq Card["act card"].acts.last
    end

    it "create works in integrate_with_delay stage" do
      with_delayed_jobs 1 do
        in_stage :integrate_with_delay, on: :create, for: "act card",
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
