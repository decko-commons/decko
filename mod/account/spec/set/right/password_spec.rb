# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Password do
  let(:account)  { Card::Auth.find_account_by_email("joe@user.com") }
  let(:password_card) { account.password_card }
  let(:password) { account.password }

  specify "view: core" do
    expect(password_card.format.render_core).to have_tag :em, "encrypted"
  end

  def card_subject
    password_card
  end

  check_views_for_errors

  describe "#update" do
    it "encrypts password", aggregate_failures: true do
      password_card.update! content: "new Pas5word!"
      expect(password).not_to eq("new password")
      authenticated = Card::Auth.authenticate "joe@user.com", "new Pas5word!"
      expect(account).to eq authenticated
    end

    it "validates password" do
      password_card.update content: "2b"
      expect(password_card.errors[:password]).not_to be_empty
    end

    context "blank password" do
      it "does not change the password", aggregate_failures: true do
        original_pw = account.password
        expect(original_pw.size).to be > 10
        password_card.update! content: ""
        expect(original_pw).to eq(password_card.refresh(_force = true).db_content)
      end

      it "does not break email editing", aggregate_failures: true do
        account.update! subcards: { "+*password" => "", "+*email" => "joe2@user.com" }
        expect(account.email).to eq("joe2@user.com")
        expect(account.password).not_to be_empty
      end
    end
  end

  context "when login or signup"
    it "renders the password view" do
      expect(password_card.format.render(:input)).to have_tag("input._toggle-password")
    end
end
