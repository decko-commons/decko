format :html do
  def account_details_items
    [
      ["Email and Password", :account,
       { path:  { view: :edit_inline } }],
      ["Roles", :roles,
       { path:  { view: :content_with_edit_button }}],
       # view: :content, slot: { show: :edit_button }}  }],
      ["Notifications", :follow]
    ]
  end

  def account_content_items
    [["Created", :created],
     ["Edited", :edited]]
  end
end
