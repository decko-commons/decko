# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Type::Signup do
  before do
    Card::Auth.signin :anonymous
  end

  let :big_bad_signup do
    Mail::TestMailer.deliveries.clear
    Card.create! name: "Big Bad Wolf", type: :signup,
                 fields: {
                   account: { fields: { email: "wolf@decko.org", password: "wolf" } }
                 }
  end

  context "signup form form" do
    subject do
      Card.new(type_id: Card::SignupID).format.render! :new
    end

    it "prompts to signup" do
      Card::Auth.as :anonymous do
        expect(subject.match(/Sign up/)).to be_truthy
      end
    end
  end

  context "signup (without approval)" do
    before do
      Card::Auth.as_bot do
        Card.create! name: "User+*type+*create", content: "Anyone"
      end
      Card::Auth.signin :anonymous

      @signup = big_bad_signup
      @account = @signup.account
    end

    it "creates all the necessary cards" do
      expect(@signup.type_id).to eq(Card::SignupID)
      expect(@account.email).to eq("wolf@decko.org")
      expect(@account.status).to eq("unverified")
      expect(@account.salt).not_to eq("")
      expect(@account.password.length).to be > 10 # encrypted
    end

    it "renders in core view" do
      Card::Auth.as_bot do
        #        puts @signup.format.render_core
        expect(@signup.format.render_core).to have_tag "div.invite-links" do
          with_tag "div", text: "A verification email has been sent to wolf@decko.org"
          with_tag "div" do
            with_tag "a", href: "/update/Big_Bad_Wolf?approve_with_verification=true",
                          text: "Resend verification email"
            with_tag "a", href: "/update/Big_Bad_Wolf?approve_without_verification=true",
                          text: "Approve without verification"
            with_tag "a", href: "/delete/Big_Bad_Wolf",
                          text: "Deny and delete"
          end
        end
      end
    end

    it "sends email with an appropriate link" do
      @mail = ActionMailer::Base.deliveries.last
      body = @mail.parts[0].body.raw_source
      expect(body).to match(Card::Rule.global_setting(:title))
    end

    it "notifies someone" do
      expect(ActionMailer::Base.deliveries.map(&:to).sort).to(
        eq [["signups@decko.org"], ["wolf@decko.org"]]
      )
    end

    it "can be activated by verification token" do
      Card::Env.params[:token] = Card::Auth::Token.encode @signup.id, anonymous: true
      account = @signup.account
      account.update! trigger: :verify_and_activate
      # puts @signup.errors.full_messages * "\n"
      expect(account.errors).to be_empty
      expect(account.status).to eq("active")
      expect(account.refresh(true)).to be_active
      expect(@signup.refresh(true).type_id).to eq(Card::UserID)
    end
  end

  context "signup (with approval)" do
    before do
      # NOTE: by default Anonymous does not have permission
      # to create User cards and thus requires approval
      Card::Auth.signin Card::AnonymousID
      @signup = big_bad_signup
      @account = @signup.account
    end

    it "creates all the necessary cards" do
      expect(@signup.type_id).to eq(Card::SignupID)
      expect(@account.email).to eq("wolf@decko.org")
      expect(@account.status).to eq("unapproved")
      expect(@account.salt).not_to eq("")
      expect(@account.password.length).to be > 10 # encrypted
    end

    it "sends signup alert email" do
      signup_alert = ActionMailer::Base.deliveries.last
      expect(signup_alert.to).to eq(["signups@decko.org"])
      [0, 1].each do |part|
        body = signup_alert.body.parts[part].body.raw_source
        expect(body).to include(@signup.name)
      end
    end

    it "does not send verification email" do
      expect(Mail::TestMailer.deliveries[-2]).to be_nil
    end

    context "when approving with verification" do
      it "sets status to 'unverified'" do
        Card::Auth.as "joe_admin"
        @signup.update! trigger: :approve_with_verification

        expect(@signup.account.status).to eq("unverified")
        expect(@signup.type_id).to eq(Card::SignupID)

        # test that verification email goes out?
      end
    end

    context "when approving without verification" do
      it "immediately converts signup to active user" do
        Card::Auth.as "joe_admin"
        @signup.update! trigger: :approve_without_verification
        expect(@signup.type_id).to eq(Card::UserID)
        expect(@signup.account).to be_active
      end
    end
  end

  context "a welcome email card exists" do
    before do
      Card::Auth.as_bot do
        Card[:welcome_email].update!(
          subcards: { "+*subject" => "welcome",
                      "+*html_message" => "Welcome {{_self|name}}" }
        )
      end
      Mail::TestMailer.deliveries.clear
      @signup = Card.create! name: "Big Bad Sheep",
                             type_id: Card::SignupID,
                             "+*account" => {
                               "+*email" => "sheep@decko.org",
                               "+*password" => "sheep"
                             }
    end

    it "sends welcome email when account is activated" do
      # @signup.run_phase :approve do
      Card::Auth.as "joe admin"
      @signup.update! trigger: :approve_without_verification
      # end
      @mail = ActionMailer::Base.deliveries.find { |a| a.subject == "welcome" }
      Mail::TestMailer.deliveries.clear

      expect(@mail).to be_truthy
      expect(@mail.body.raw_source).to include("Welcome Big Bad Sheep")
    end
  end

  context "invitation" do
    before do
      # NOTE:
      # by default Anonymous does not have permission to create User cards.
      Card::Auth.signin Card::WagnBotID
      @signup = big_bad_signup
      @account = @signup.account
    end

    it "creates all the necessary cards" do
      expect(@signup.type_id).to eq(Card::SignupID)
      expect(@account.email).to eq("wolf@decko.org")
      expect(@account.status).to eq("unverified")
      expect(@account.salt).not_to eq("")
    end

    it "considers signups created by signed-in users to be invitations" do
      expect(@signup.format.invitation?).to be(true)
    end
  end

  # describe '#signup_notifications' do
  #   before do
  #     Card::Auth.as_bot do
  #       Card.create! name: '*request+*to', content: 'signups@decko.org'
  #     end
  #     @user_name = 'Big Bad Wolf'
  #     @user_email = 'wolf@decko.org'
  #     @signup = Card.create! name: @user_name, type_id: Card::SignupID,
  #                            '+*account'=>{
  #       '+*email'=>@user_email, '+*password'=>'wolf'}
  #     ActionMailer::Base.deliveries = []
  #     @signup.signup_notifications
  #     @mail = ActionMailer::Base.deliveries.last
  #   end
  #
  #   it 'send to correct address' do
  #     expect(@mail.to).to eq(['signups@decko.org'])
  #   end
  #
  #   it 'contains request url' do
  #      expect(@mail.body.raw_source).to include(card_url(@signup))
  #   end
  #
  #   it 'contains user name' do
  #     expect(@mail.body.raw_source).to include(@user_name)
  #   end
  #
  #   it 'contains user email' do
  #     expect(@mail.body.raw_source).to include(@user_email)
  #   end
  # end
end
