def account
  fetch trait: :account, new: {}
end

def default_account_status
  "active"
end

format :html do
  def account_formgroups
    Auth.as_bot do
      subformat(card.account)._render :content_formgroups, structure: true
    end
  end
end
