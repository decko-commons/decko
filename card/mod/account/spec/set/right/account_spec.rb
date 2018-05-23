# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Account do
  describe "#create" do
    context "valid user" do
      # note - much of this is tested in account_request_spec
      before do
        Card::Auth.as_bot do
          @user_card = Card.create!(
            name: "TmpUser",
            type_id: Card::UserID,
            "+*account" => {
              "+*email" => "tmpuser@wagn.org", "+*password" => "tmp_pass"
            }
          )
        end
      end

      it "creates an authenticable password" do
        validity = Card::Auth.password_valid? @user_card.account, "tmp_pass"
        expect(validity).to be_truthy
      end
    end

    it "checks accountability of 'accounted' card" do
      @unaccountable = Card.create(
        name: "BasicUnaccountable",
        "+*account" => {
          "+*email" => "tmpuser@wagn.org",
          "+*password" => "tmp_pass"
        }
      )
      error_msg = @unaccountable.errors["+*account"].first
      expect(error_msg).to eq("not allowed on this card")
    end

    it "requires email" do
      @no_email = Card.create(
        name: "TmpUser",
        type_id: Card::UserID,
        "+*account" => { "+*password" => "tmp_pass" }
      )
      expect(@no_email.errors["+*account"].first).to match(/email required/)
    end
  end

  describe "#send_account_verification_email" do
    before do
      @email = "joe@user.com"
      @account = Card::Auth.find_account_by_email(@email)
      Mail::TestMailer.deliveries.clear
      @account.send_account_verification_email
      @mail = Mail::TestMailer.deliveries.last
    end

    it "has correct address" do
      expect(@mail.to).to eq([@email])
    end

    it "contains deck title" do
      body = @mail.parts[0].body.raw_source
      expect(body).to match(Card.global_setting(:title))
    end

    it "contains link to verify account" do
      raw_source = @mail.parts[0].body.raw_source
      ["/update/#{@account.left.name.url_key}",
       "token=#{@account.token}"].each do |url_part|
        expect(raw_source).to include(url_part)
      end
    end

    it "contains expiry days" do
      msg = "valid for #{Card.config.token_expiry / 1.day} days"
      expect(@mail.parts[0].body.raw_source).to include(msg)
    end
  end

  describe "#send_reset_password_token" do
    before do
      @email = "joe@user.com"
      @account = Card::Auth.find_account_by_email(@email)
      Mail::TestMailer.deliveries = []
      @account.send_reset_password_token
      @mail = Mail::TestMailer.deliveries.last
    end

    it "contains deck title" do
      body = @mail.parts[0].body.raw_source
      expect(body).to match(Card.global_setting(:title))
    end

    it "contains password reset link" do
      raw_source = @mail.parts[0].body.raw_source
      token = @account.token_card.refresh(true).content
      ["/update/#{@account.left.name.url_key}",
       "token=#{token}",
       "live_token=true",
       "event=reset_password"].each do |url_part|

        expect(raw_source).to include(url_part)
      end
    end

    it "contains expiry days" do
      url = "valid for #{Card.config.token_expiry / 1.day} days"
      expect(@mail.parts[0].body.raw_source).to include(url)
    end
  end

  describe "#update_attributes" do
    before do
      @account = Card::Auth.find_account_by_email("joe@user.com")
    end

    it "resets password" do
      @account.password_card.update_attributes!(content: "new password")
      authenticated = Card::Auth.authenticate "joe@user.com", "new password"
      assert_equal @account, authenticated
    end

    it "does not rehash password when updating email" do
      @account.email_card.update_attributes! content: "joe2@user.com"
      authenticated = Card::Auth.authenticate "joe2@user.com", "joe_pass"
      assert_equal @account, authenticated
    end
  end

  describe "#reset_password" do
    before do
      @email = "joe@user.com"
      @account = Card::Auth.find_account_by_email(@email)
      @account.send_reset_password_token
      @token = @account.token
      Card::Env.params[:token] = @token
      Card::Env.params[:event] = "reset_password"
      Card::Auth.current_id = Card::AnonymousID
    end

    it "authenticates with correct token" do
      expect(Card::Auth.current_id).to eq(Card::AnonymousID)
      expect(@account.save).to eq(true)
      expect(Card::Auth.current_id).to eq(@account.left_id)
      @account = @account.refresh true
      # expect(@account.fetch(trait: :token)).to be_nil
    end

    it "does not work if token is expired" do
      @account.token_card.update_column :updated_at,
                                        3.days.ago.strftime("%F %T")
      @account.token_card.expire
      result = @account.save

      expect(result).to eq(true)
      # successfully completes save

      expect(@account.token).not_to eq(@token)
      # token gets updated

      expect(@account.success.message).to match(/expired/)
      # user notified of expired token
    end

    it "does not work if token is wrong" do
      Card::Env.params[:token] = @token + "xxx"
      Card::Env.params[:event] = "reset_password"
      @account.save
      expect(@account.errors[:incorrect_token].first).to match(/mismatch/)
    end
  end
end
