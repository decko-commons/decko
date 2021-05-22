# -*- encoding : utf-8 -*-

# FIXME: need more specific assertions

RSpec.describe Card::Set::Self::Signin do
  before do
    @card = Card[:signin]
  end

  it "open view should have email and password fields" do
    open_view = @card.format.render_open
    expect(open_view).to match(/email/)
    expect(open_view).to match(/password/)
  end

  it "edit view should prompt for forgot password" do
    edit_view = @card.format.render_edit
    expect(edit_view).to match(/email/)
    expect(edit_view).to match(/reset_password/)
  end

  it "password reset success view should prompt to check email" do
    rps_view = @card.format.render_reset_password_success
    expect(rps_view).to match(/Check your email/)
  end

  it "delete action should sign out account" do
    expect(Card::Auth.current_id).to eq(Card["joe_user"].id)
    @card.delete
    expect(Card::Auth.current_id).to eq(Card::AnonymousID)
  end

  describe "#update" do
    it "triggers signin with valid credentials" do
      @card.update! "+*email" => "joe@admin.com",
                    "+*password" => "joe_pass"
      expect(Card::Auth.current).to eq(Card["joe admin"])
    end

    it "does not trigger signin with bad email" do
      @card.update! "+*email" => "schmoe@admin.com",
                    "+*password" => "joe_pass"
      expect(@card.errors[:signin].first).to match(/Unrecognized email/)
    end

    it "does not trigger signin with bad password" do
      @card.update! "+*email" => "joe@admin.com",
                    "+*password" => "joe_fail"
      expect(@card.errors[:signin].first).to match(/Wrong password/)
    end
  end

  describe "#reset password" do
    it "is triggered by an update" do
      # Card['joe admin'].account.token.should be_nil FIXME:  this should be t
      @card.update! "+*email" => "joe@admin.com", trigger: :send_reset_password_token
      expect(Mail::TestMailer.deliveries.last.to.first).to eq("joe@admin.com")
    end

    it "returns an error if email is not found" do
      @card.update! "+*email" => "schmoe@admin.com", trigger: :send_reset_password_token
      expect(@card.errors[:email].first).to match(/not recognized/)
    end
  end
end
