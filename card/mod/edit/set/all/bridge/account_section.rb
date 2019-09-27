format :html do
  def account_details_items
    [
      ["Email and Password", :account,
       { path: { slot: { hide: %i[help_link bridge_link] } } }],
      ["Roles", :roles,
       { path:  { view: :content_with_edit_button } }],
      ["Notifications", :follow]
    ]
  end

  def account_content_items
    [["Created", :created],
     ["Edited", :edited]]
  end
end
