RSpec.describe Card::Set::Right::Account::Events do
  let(:account) { accounted_id.card.account }
  let(:accounted_id) { "Joe Camel".card_id }
  let(:accounted_child) { Card.create! name: "Joe Camel+child" }

  def delete_account!
    account.delete! trigger: :delete_account
  end

  describe "event #delete_account" do
    it "deletes account and anonymizes", as_bot: true do
      delete_account!
      expect(account.id.card).to be_nil
      expect(accounted_id.card.name).to match(/ANON/)
    end

    it "deletes children", as_bot: true do
      expect(accounted_child.id.card).to be_a(Card)
      delete_account!
      expect(accounted_child.id.card).to be_nil
    end
  end
end
