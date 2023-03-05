def account
  fetch :account, new: {}
end

def default_account_status
  "active"
end

def current_account?
  id && Auth.current_id == id
end

format :html do
  def default_bridge_tab
    card.current_account? ? :account_tab : super
  end

  view :account_tab do
    bridge_pill_sections "Account" do
      [["Settings", account_details_items],
       ["Content", account_content_items]]
    end
  end

  def show_account_tab?
    card.account.real?
  end

  def account_formgroups
    Auth.as_bot do
      subformat(card.account)._render :content_formgroups, structure: true
    end
  end

  def account_details_items
    [
      ["Email and Password", :account,
       { path: { slot: { hide: %i[help_link bridge_link] } } }],
      ["Roles", :roles,
       { path:  { view: :content,
                  slot: { show: :edit_button } } }],
      ["Notifications", :follow],
      ["API", :account,
       { path: { view: :api_key,
                 items: { view: :content },
                 slot: { hide: %i[help_link bridge_link] } } }]
    ]
  end

  def account_content_items
    [["Created", :created],
     ["Edited", :edited]]
  end
end
