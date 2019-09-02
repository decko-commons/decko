# -*- encoding : utf-8 -*-

RSpec.describe Card::Set::Right::Account do
  describe "#create" do
    let(:dummy_account_args) do
      {
        name: "TmpUser",
        "+*account" => {
          "+*email" => "tmpuser@wagn.org",
          "+*password" => "tmp_pass"
        }
      }
    end

    context "valid user" do
      # note - much of this is tested in account_request_spec
      before do
        Card::Auth.as_bot do
          @user_card = Card.create! dummy_account_args.merge(type_id: Card::UserID)
        end
      end

      it "creates an authenticable password" do
        validity = Card::Auth.password_valid? @user_card.account, "tmp_pass"
        expect(validity).to be_truthy
      end
    end

    it "checks accountability of 'accounted' card" do
      expect(Card.create(dummy_account_args).errors["+*account"].first)
        .to match(/You don\'t have permission to create/)
    end

    it "works for any card with +*account permissions -- not just User type" do
      Card::Auth.as_bot do
        Card.create! name: Card::Name[%i[basic account type_plus_right create]],
                     content: "Anyone Signed In"
      end

      expect(Card.create(dummy_account_args).errors).to be_empty
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
       "card%5Btrigger%5D=reset_password"].each do |url_part|
        expect(raw_source).to include(url_part)
      end
    end

    it "contains expiry days" do
      url = "valid for #{Card.config.token_expiry / 1.day} days"
      expect(@mail.parts[0].body.raw_source).to include(url)
    end
  end

  describe "#update" do
    before do
      @account = Card::Auth.find_account_by_email("joe@user.com")
    end

    it "resets password" do
      @account.password_card.update!(content: "new password")
      authenticated = Card::Auth.authenticate "joe@user.com", "new password"
      assert_equal @account, authenticated
    end

    it "does not rehash password when updating email" do
      @account.email_card.update! content: "joe2@user.com"
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
      Card::Auth.current_id = Card::AnonymousID
    end

    let(:trigger_reset) { @account.update! trigger: :reset_password }

    it "authenticates with correct token" do
      expect(Card::Auth.current_id).to eq(Card::AnonymousID)
      trigger_reset
      expect(Card::Auth.current_id).to eq(@account.left_id)
      @account = @account.refresh true
    end

    it "does not work if token is expired" do
      @account.token_card.update_column :updated_at,
                                        3.days.ago.strftime("%F %T")
      @account.token_card.expire

      trigger_reset

      expect(@account.token).not_to eq(@token)
      # token gets updated

      expect(@account.success.message).to match(/expired/)
      # user notified of expired token
    end

    it "does not work if token is wrong" do
      Card::Env.params[:token] = @token + "xxx"
      trigger_reset
      expect(Card::Env.success[:message]).to match(/mismatch/)
    end
  end
end
