format :html do
  def link_to_mycard
    link_to_card Auth.current.name, nil,
                 id: "my-card-link", class: "nav-link #{classy('my-card')}"
  end

  def account_dropdown &render_role_item
    split_button link_to_mycard, nil do
      [
        link_to_card([Auth.current, :account_settings], "Account"),
        render_sign_out,
        (["Roles", role_items(&render_role_item)] if special_roles?)
      ]
    end
  end

  def special_roles?
    Auth.current_roles.size > 1
  end

  def role_items &block
    Auth.current_roles.map(&block)
  end
end
