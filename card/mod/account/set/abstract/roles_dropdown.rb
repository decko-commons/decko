format :html do
  def link_to_mycard
    link_to_card Auth.current.name, nil,
                 id: "my-card-link", class: "nav-link #{classy('my-card')}"
  end

  def roles_dropdown role_list
    split_button link_to_mycard, nil do
      [
        link_to_card([Auth.current, :account_settings], "Account"),
        ["Roles", role_list]
      ]
    end
  end
end
