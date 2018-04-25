# -*- encoding : utf-8 -*-

shared_examples_for "notifications" do
  let(:created) { Card["Created card"] }
  let(:updated) { Card["Updated card"] }
  let(:deleted) { Card.fetch("Deleted card", look_in_trash: true) }

  describe "#list_of_changes" do
    def list_of_changes card, action=nil
      args = action ? { action_id: action.id } : {}
      card.format(format: format).render_list_of_changes args
    end

    example "for a new card" do
      expect(list_of_changes(created))
        .to include("content: new content", "cardtype: Basic")
    end

    example "for a updated card" do
      expect(list_of_changes(updated))
        .to include("new content: [[changed content]]",
                    "new cardtype: Pointer",
                    "new name: Updated card")
    end

    example "for a deleted card" do
      expect(list_of_changes(deleted)).to be_empty
    end

    example "for a given action" do
      action = updated.create_action
      expect(list_of_changes(updated, action))
        .to include "content: new content"
    end
  end

  describe "subedit_notice" do
    def subedit_notice card
      card.format(format: format).render_subedit_notice
    end

    example "for a created card" do
      expect(subedit_notice(created))
        .to include("Created card", "created", "new content")
    end

    example "for an updated card" do
      expect(subedit_notice(updated))
        .to include("Updated card", "updated", "changed content")
    end

    example "for a deleted card" do
      expect(subedit_notice(deleted))
        .to include("Deleted card", "deleted")
    end
  end
end

RSpec.describe Card::Set::All::SendNotifications do
  before do
    ::Card.any_instance.stub(:'silent_change?').and_return(false)
  end

  def notification_email_for card_name, followed_set: "#{card_name}+*self"
    follower = Card["Joe User"]
    context = Card[card_name].refresh(true)
    Card[:follower_notification_email].format.mail(
      context, { to: follower.email }, auth: follower,
                                       active_notice: { follower: follower.name,
                                                        followed_set:  followed_set,
                                                        follow_option: "*always" }
    ).text_part.body.raw_source
  end

  describe "content of notification email" do

    context "for new card with subcards" do
      specify do
        expect(notification_email_for "card with fields")
          .to include("main content", "content of field 1" , "content of field 2")
      end

      context "and missing permissions" do
        example "for a field" do
            expect(notification_email_for("card with fields and admin fields"))
              .to not_include("content of admin field 1")
                    .and include("content of field 1")
        end

        example "for main card" do
          card_name = "admin card with fields and admin fields"
          email = notification_email_for card_name,
                                         followed_set: "#{card_name}+field 1+*self"
          expect(email).to include("content of field 1").and not_include("main content")
        end

        example "for all parts" do
          card = Card["admin card with admin fields"]
            expect("admin card with admin fields")
              .to not_include("main content").and not_include("content of admin field 1")
                                             .and not_include("content of admin field 2")
            expect(Card["Joe User"].account.changes_visible?(card.acts.last))
                          .to be_falsey
        end
      end
    end
  end

  describe "html format" do
    include_examples "notifications" do
      let(:format) { "email_html" }
    end
  end

  describe "text format" do
    include_examples "notifications" do
      let(:format) { "email_text" }
    end

    it "creates well formatted text message" do
      unfollow_link =
        "/update/Joe_User+*follow?card%5Bsubcards%5D%5B"\
        "card+with+fields%2B%2Aself%2BJoe+User%2B%2Afollow%5D=%2Anever"

      expect(notification_email_for("card with fields"))
        .to eq(
      <<-TEXT
"card with fields" was just created by Joe User.

   cardtype: Basic
   content: main content {{+field 1}}  {{+field 2}}



This update included the following changes:

card with fields+field 1 created
   cardtype: Basic
   content: content of field 1


card with fields+field 2 created
   cardtype: Basic
   content: content of field 2




See the card: /card_with_fields

You received this email because you're following "card with fields".

Use this link to unfollow #{unfollow_link}
TEXT
)
    end
  end

  describe "#notify_followers" do
    def expect_user user_name
      expect(Card.fetch(user_name).account)
    end

    def be_notified
      receive(:send_change_notice)
    end

    def be_notified_of set_name, option_name="*always"
      receive(:send_change_notice)
        .with(kind_of(Card::Act), set_name, option_name)
    end

    def update card_name, new_content="updated content"
      Card[card_name].update_attributes! content: new_content
    end

    def update_name card_name, new_name="updated content"
      Card[card_name].update_attributes! name: new_name, update_referers: true
    end

    it "sends notifications of edits" do
      expect_user("Big Brother").to be_notified_of "All Eyes On Me+*self"
      update "All Eyes On Me"
    end

    it "does not send notification to author of change" do
      Card::Auth.current_id = Card["Big Brother"].id
      expect_user("Big Brother").not_to be_notified
      update "Google glass"
    end

    it "sends only one notification per user"  do
      expect_user("Big Brother").to receive(:send_change_notice).exactly(1)
      update "Google glass"
    end

    it "sends only one notification per user"  do
      Card.create! name: "WOW", content: "{{Big Brother|link}}"
      Card::Auth.as_bot do
        Card.create! name: "Users+*type+John+*follow", type_id: Card::PointerID,
                     content: "[[*always]]\n"
      end
      expect_user("John").to receive(:send_change_notice).exactly(1)
      update_name "Big Brother"
    end

    it "does not send notification of not-followed cards" do
      expect_user("Big Brother").not_to be_notified
      update "No One Sees Me"
    end

    context "when following *type sets" do
      before do
        Card::Auth.current_id = Card["joe admin"].id
      end

      it "sends notifications of new card" do
        new_card = Card.new name: "Microscope", type: "Optic"
        expect_user("Optic fan").to be_notified_of "Optic+*type", "*always"
        new_card.save!
      end

      it "sends notification of update" do
        expect_user("Optic fan").to be_notified_of "Optic+*type", "*always"
        update "Sunglasses"
      end
    end

    context "when following *right sets" do
      it "sends notifications of new card" do
        new_card = Card.new name: "Telescope+lens"
        expect_user("Big Brother").to be_notified_of "lens+*right", "*always"
        new_card.save!
      end

      it "sends notifications of update" do
        expect_user("Big Brother").to be_notified_of "lens+*right", "*always"
        update "Magnifier+lens"
      end
    end

    context 'when following "*created"' do
      it "sends notifications of update" do
        expect_user("Narcissist").to be_notified_of "*all", "*created"
        update "Sunglasses"
      end
    end

    context 'when following "content I edited"' do
      it "sends notifications of update" do
        expect_user("Narcissist").to be_notified_of "*all", "*edited"
        update "Magnifier+lens"
      end
    end

    describe "notifications of fields" do
      context "when following ascendant" do
        it "doesn't sends notification of arbitrary subcards" do
          expect_user("Sunglasses fan").not_to be_notified
          Card.create name: "Sunglasses+about"
        end

        context "and follow fields rule contains subcards" do
          it "sends notification of new subcard" do
            new_card = Card.new name: "Sunglasses+producer"
            expect_user("Sunglasses fan")
              .to be_notified_of "Sunglasses+*self", "*always"
            new_card.save!
          end

          it "sends notification of updated subcard" do
            expect_user("Sunglasses fan")
              .to be_notified_of "Sunglasses+*self", "*always"
            update "Sunglasses+price"
          end
        end

        context "and follow fields rule contains *include" do
          it "sends notification of new included card" do
            new_card = Card.new name: "Sunglasses+lens"
            expect_user("Sunglasses fan").to be_notified_of "Sunglasses+*self"
            new_card.save!
          end

          it "sends notification of updated included card" do
            expect_user("Sunglasses fan").to be_notified_of "Sunglasses+*self"
            update "Sunglasses+tint"
          end

          it "doesn't send notification of not included card" do
            new_card = Card.new name: "Sunglasses+frame"
            expect_user("Sunglasses fan").not_to be_notified
            new_card.save!
          end
        end

        context "and follow fields rule doesn't contain *include" do
          it "doesn't send notification of included card" do
            expect_user("Big Brother").not_to be_notified
            Card.create! name: "Google glass+price"
          end
        end
      end
      context "when following a set" do
        it "sends notification of included card" do
          expect_user("Optic fan").to be_notified_of "Optic+*type"
          update "Sunglasses+tint"
        end

        it "sends notification of subcard mentioned in follow fields rule" do
          expect_user("Optic fan").to be_notified_of "Optic+*type"
          update "Sunglasses+price"
        end
      end
    end
  end
end
