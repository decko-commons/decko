# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::All::History do
  describe "history view" do
    it "has a frame" do
      history = render_card :history, name: "A"
      assert_view_select history, 'div[class~="d0-card-frame"]'
    end

    describe "#action_summary" do
      subject do
        Card.fetch("First").format.render_action_summary
      end

      it "has a summary" do
        assert_view_select subject, 'del[class="diffdel diff-deleted"]',
                           text: "chicken"
        assert_view_select subject, 'ins[class="diffins diff-added"]',
                           text: "chick"
      end
    end
  end

  describe "#create_act_and_action" do
    let!(:act_start_cnt) { Card::Act.count }
    let(:content) { "Nobody expects the Spanish inquisition" }
    let(:act) { card.acts.last }
    let(:action) { act.actions.last }

    INITIAL_VALUES = {
      name: "single card",
      type_id: Card::BasicID.to_s,
      db_content: "Nobody expects the Spanish inquisition",
      trash: "f",
      left_id: nil,
      right_id: nil
    }.freeze

    context "with for single card" do
      let :card do
        Card::Auth.as_bot { Card.create name: "single card", content: content }
      end

      context "when created" do
        it "adds new act" do
          act_start_cnt
          card
          expect(Card::Act.count).to eq(act_start_cnt + 1)
          expect(act.card_id).to eq(card.id)
          expect(act.acted_at).to be > Time.zone.now - 1.minute
        end

        it "adds create action" do
          expect(action.action_type).to eq(:create)
        end

        it "does not add card changes entries" do
          expect(action.card_changes).to be_empty
        end

        it "fetches card changes from cards table" do
          expect(action.changed_values).to eq(INITIAL_VALUES)
        end
      end

      context "when updated" do
        it "adds no act if nothing changed" do
          pending "act handling upgrade"
          card.update name: "single card", content: content
          expect(Card::Act.count).to eq(act_start_cnt + 1)
        end

        it "adds new act" do
          card.update content: "new content"
          expect(Card::Act.count).to eq(act_start_cnt + 2)
        end

        it "adds changes to create action" do
          card.update content: "new content"
          expect(card.actions.first.changed_values).to eq INITIAL_VALUES
        end
      end

      context "when deleted" do
        before do
          Card::Auth.as_bot { card.delete }
        end

        it "adds act" do
          expect(Card::Act.count).to eq(act_start_cnt + 2)
        end

        it "adds delete action" do
          expect(action.action_type).to eq(:delete)
        end

        it "adds trash change" do
          expect(action.card_changes.last.field).to eq("trash")
          expect(action.card_changes.last.value).to be_truthy
        end

        it "adds changes to create action" do
          expect(card.actions.first.changed_values).to eq INITIAL_VALUES
        end
      end

      context "when creation fails" do
        it "doesn't create an act" do
          Card::Auth.as(:anonymous) do
            act_count = Card::Act.count
            Card.create name: "create fail"
            expect(Card::Act.count).to eq act_count
          end
        end

        it "doesn't create an action" do
          Card::Auth.as(:anonymous) do
            action_count = Card::Action.count
            Card.create name: "create fail"
            expect(Card::Action.count).to eq action_count
          end
        end

        it "doesn't create act and actions if subcard fails" do
          Card::Auth.as("joe_user") do
            act_count = Card::Act.count
            action_count = Card::Action.count
            Card.create name: "create fail", subcards: { "*all+*create" => "" }
            expect(Card::Action.count).to eq action_count
            expect(Card::Act.count).to eq act_count
          end
        end
      end
    end

    context "with subcard" do
      let :card do
        Card::Auth.as_bot do
          content = "Nobody expects the Spanish inquisition"
          Card.create! name: "left", subcards: { "+right" => { content: content } }
        end
      end

      let(:left_action) { act.actions[0] }
      let(:right_action) { act.actions[2] }
      let(:plus_action) { act.actions[1] }

      context "when created" do
        it "adds only a act for left card" do
          act_start_cnt
          card
          expect(Card::Act.count).to eq(act_start_cnt + 1)
          expect(act.card).to eq(card)
        end

        it "adds three actions" do
          expect(act.actions.size).to eq(3)
        end

        it "adds action for left part of type create" do
          expect(left_action.card.name).to eq("left")
          expect(left_action.action_type).to eq(:create)
        end

        it "adds action for right part of type create" do
          expect(right_action.card.name).to eq("right")
          expect(right_action.action_type).to eq(:create)
        end

        it "adds action for plus card of type create" do
          expect(plus_action.card.name).to eq("left+right")
          expect(plus_action.action_type).to eq(:create)
        end

        it "adds content change" do
          changed_content = plus_action.value(:db_content)
          expect(changed_content).to eq(content)
        end

        it "adds superaction for plus card" do
          expect(plus_action.super_action_id).to eq(left_action.id)
        end
      end

      context "when updated" do
        it "adds act for left card" do
          card.update subcards: {
            "+right" => {
              content: "New content", db_content: "New Content"
            }
          }
          expect(Card::Act.count).to eq(act_start_cnt + 2)
          expect(act.card).to eq(card)
        end

        it "adds action for subcard" do
          card.update subcards: {
            "+right" => { content: "New Content" }
          }
          expect(act.actions.count).to eq(1)
          expect(act.actions.last.action_type).to eq(:update)
          expect(act.actions.last.card.name).to eq("left+right")
        end
      end
    end

    context "with plus card adds" do
      let :card do
        Card::Auth.as_bot do
          content = "Nobody expects the Spanish inquisition"
          Card.create name: "left+right", content: content
        end
      end

      let(:left_action) { act.actions[1] }
      let(:right_action) { act.actions[2] }
      let(:plus_action) { act.actions[0] }

      it "only a act for plus card" do
        act_start_cnt
        expect(act.card_id).to eq(card.id)
        expect(Card::Act.count).to eq(act_start_cnt + 1)
      end

      it "three actions" do
        act = card.acts.last
        expect(act.actions.size).to eq(3)
      end

      it "action for left part of type create" do
        expect(left_action.card.name).to eq("left")
        expect(left_action.action_type).to eq(:create)
      end

      it "superaction for left part" do
        expect(left_action.super_action_id).to eq(plus_action.id)
      end

      it "action for right part of type create" do
        expect(right_action.card.name).to eq("right")
        expect(right_action.action_type).to eq(:create)
      end

      it "action for plus card of type create" do
        expect(plus_action.card.name).to eq("left+right")
        expect(plus_action.action_type).to eq(:create)
      end

      it "content change" do
        expect(plus_action.value(:db_content)).to eq(content)
      end
    end
  end

  describe "timestamping" do
    # NOTE: B includes Z, so updates to Z stamp B
    example "includers get a new timestamp",
            with_user: "Sample User", aggregate_failures: true do
      time = Time.now - 1.second
      expect(Card["B"].updated_at).to be < time
      expect(Card["B"].updater_id).not_to eq "Sample User".card_id

      Card["Z"].update! content: "new content"

      expect(Card["B"].updated_at).to be > time
      expect(Card["B"].updater_id).to eq "Sample User".card_id
    end
  end
end
