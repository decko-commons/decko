format :html do
  def link_to_mycard text=nil
    link_to_card Auth.current.name, text,
                 id: "my-card-link", class: "nav-link #{classy('my-card')}"
  end

  def account_dropdown
    class_up "dropdown-toggle-split", "nav-link"
    split_dropdown_button account_dropdown_label do
      account_dropdown_items
    end
  end

  private

  def account_dropdown_label
    link_to_mycard
  end

  def account_dropdown_items
    [[[Auth.current, :account_settings], "Account"],
     [:signin, t("account_sign_out"), { path: { action: :delete } }]] +
      account_dropdown_roles
  end

  def account_dropdown_roles
    return [] unless special_roles?

    [dropdown_header("Roles")] + account_dropdown_role_items
  end

  def account_dropdown_role_items
    Auth.current_roles.map { |role| [role] }
  end

  def special_roles?
    Auth.current_roles.size > 1
  end

  def role_items &block
    Auth.current_roles.map(&block)
  end
end
