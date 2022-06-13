format :html do
  def link_to_mycard
    link_to_card Auth.current.name, nil,
                 id: "my-card-link", class: "nav-link #{classy('my-card')}"
  end

  def account_dropdown &render_role_item
    split_dropdown_button link_to_mycard do
      [
        [[Auth.current, :account_settings], "Account"],
        [:signin, t("account_sign_out"), { path: { action: :delete } }]
      ] + account_dropdown_roles(&render_role_item)
    end
  end

  private

  def account_dropdown_roles &block
    return [] unless special_roles?

    [dropdown_header("Roles")] +
      Auth.current_roles.map { |role| block_given? ? block.call(role) : [role] }
  end

  def special_roles?
    Auth.current_roles.size > 1
  end

  def role_items &block
    Auth.current_roles.map(&block)
  end
end
