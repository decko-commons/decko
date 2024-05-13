include_set Abstract::AccountDropdown

def ok_to_read?
  true
end

format :html do
  delegate :signed_in?, to: Card::Auth

  view :core, cache: :never do
    status_class = Auth.signed_in? ? "logged-in" : "logged-out"
    wrap_with :div, id: "logging", class: status_class do
      navbar_items.join "\n"
    end
  end

  def navbar_items
    # removed invite for now
    navbar_item_views.map do |link_view|
      rendered = render link_view
      wrap_with_nav_item rendered if rendered.present?
    end.compact
  end

  def navbar_item_views
    %i[my_card sign_out sign_up sign_in]
  end

  def self.link_options perms
    { denial: :blank, cache: :never, perms: perms }
  end

  view :sign_up, link_options(:show_signup_link?) do
    link_to_card :signup, account_link_text(:sign_up),
                 class: nav_link_class("signup-link"),
                 path: { action: :new, mark: :signup }
  end

  view :sign_in, link_options(:not_signed_in?) do
    link_to_card :signin, account_link_text(:sign_in),
                 class: nav_link_class("signin-link")
  end

  view :sign_out, link_options(:signed_in?) do
    link_to_card :signin, account_link_text(:sign_out),
                 class: nav_link_class("signout-link"),
                 path: { action: :delete }
  end

  view :invite, link_options(:show_invite_link?) do
    link_to_card :signup, account_link_text(:invite),
                 class: nav_link_class("invite-link"),
                 path: { action: :new, mark: :signup }
  end

  view :my_card, link_options(:signed_in?) do
    can_disable_roles? ? interactive_roles_dropdown : account_dropdown
  end

  def interactive_roles_dropdown
    nest enabled_roles_card,
         view: :edit_inline, hide: %i[edit_inline_buttons name_formgroup]
  end

  def enabled_roles_card
    Auth.current.fetch :enabled_roles, new: { type_id: SessionID }
  end

  def role_list
    Auth.current_roles.map(&method(:link_to_card))
  end

  def can_disable_roles?
    Auth.current_roles.size > 1 &&
      Card::Codename.exists?(:enabled_roles) # workaround for broken migrations
  end

  def account_link_text purpose
    voo.title || t("account_#{purpose}")
  end

  def nav_link_class type
    "nav-link #{classy(type)}"
  end

  def not_signed_in?
    !Auth.signed_in?
  end

  def show_signup_link?
    not_signed_in? && Card.new(type: :signup).ok?(:create)
  end

  def show_invite_link?
    Auth.signed_in? &&
      Card.new(type_id: Card.default_accounted_type_id).ok?(:create)
  end
end
