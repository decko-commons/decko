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
        .to include("content: new content", "cardtype: RichText")
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

RSpec.describe Card::Set::All::Notify do
  # typically notifications are not sent on non-web-requests
  before { described_class.force_notifications = true }

  after { described_class.force_notifications = false }

  def notification_email_for card_name, followed_set: "#{card_name}+*self"
    follower = Card["Joe User"]
    context = Card[card_name].refresh(true)
    Card[:follower_notification_email].format.mail(
      context, { to: follower.email }, auth: follower,
                                       active_notice: { follower: follower.name,
                                                        followed_set: followed_set,
                                                        follow_option: "*always" }
    ).text_part.body.raw_source
  end

  describe "content of notification email" do
    context "when new card with subcards" do
      specify do
        expect(notification_email_for("card with fields"))
          .to include("main content", "content of field 1", "content of field 2")
      end

      context "with missing permissions" do
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

        context "with multiple restricted parts" do
          let(:admin_card) { "admin card with admin fields" }
          let(:notification_email) { notification_email_for admin_card }

          it "does not notify about restricted content" do
            expect(notification_email)
              .to not_include("main content")
              .and not_include("content of admin field 1")
              .and not_include("content of admin field 2")
          end

          # FIXME: does this really test anything?
          # the notification email doesn't represent an actual change
          it "does not show up as a visible change to non-admin user" do
            notification_email
            expect(Card["Joe User"].account)
              .not_to be_changes_visible(Card[admin_card].acts.last)
          end
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
      path = File.expand_path "notify_email.txt", __dir__
      email = notification_email_for("card with fields").delete "\r"
      expect(email).to eq(File.read(path))
    end
  end

  describe "#notify_followers" do
    # Normally, delayed events renew the cache, which entails clearing the local cache.
    # That breaks these tests, because if the local cache is cleared, then the +*account
    # card that receives the :send_change_notice method is a _different_ object than
    # the one expecting it.
    #
    # An alternative approach would be to insert _only_ the account object into the
    # cache when the delayed job is started.  This would more reliably test that the
    # delayed job can get everything it needs with a clean cache.
    before { Card::Cache.no_renewal = true }
    after { Card::Cache.no_renewal = false }

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
      Card[card_name].update! content: new_content
    end

    def update_name card_name, new_name="updated content"
      Card[card_name].update! name: new_name, update_referers: true
    end

    def self.notify_on_create user, trigger, create_name
      it "sends notifications of new card" do
        expect_user(user).to be_notified_of trigger, "*always"
        create_args = create_name.is_a?(String) ? { name: create_name } : create_name
        Card.create! create_args
      end
    end

    def self.notify_on_update user, trigger, update_name
      it "sends notifications of update" do
        expect_user(user).to be_notified_of trigger, "*always"
        update update_name
      end
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

    it "sends notification of name updates"  do
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

    notify_on_create "Optic fan", "Optic+*type", name: "Microsoft", type: "Optic"
    notify_on_update "Optic fan", "Optic+*type", "Sunglasses"

    notify_on_create "Big Brother", "lens+*right", "Telescope+lens"
    notify_on_update "Big Brother", "lens+*right", "Magnifier+lens"

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
      context "when following parent" do
        it "doesn't sends notification of arbitrary subcards" do
          expect_user("Sunglasses fan").not_to be_notified
          Card.create name: "Sunglasses+about"
        end

        notify_on_create "Sunglasses fan", "Sunglasses+*self", "Sunglasses+producer"
        notify_on_update "Sunglasses fan", "Sunglasses+*self", "Sunglasses+price"

        context "when follow fields rule contains *include" do
          notify_on_create "Sunglasses fan", "Sunglasses+*self", "Sunglasses+lens"
          notify_on_update "Sunglasses fan", "Sunglasses+*self", "Sunglasses+tint"

          it "doesn't send notification of not included card" do
            expect_user("Sunglasses fan").not_to be_notified
            Card.create! name: "Sunglasses+frame"
          end
        end

        context "when follow fields rule doesn't contain *include" do
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
