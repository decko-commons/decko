format :html do
  def link_to_mycard
    link_to_card Auth.current.name, nil,
                 id: "my-card-link", class: "nav-link #{classy('my-card')}"
  end

  def account_dropdown &render_role_item
    split_button link_to_mycard, nil do
      [
        link_to_card([Auth.current, :account_settings], "Account"),
        (["Roles", role_items(&render_role_item)] unless Auth.no_special_roles?)
      ]
    end
  end

  def role_items
    Auth.current_roles.map do |role_name|
      yield role_name
    end
  end
end
