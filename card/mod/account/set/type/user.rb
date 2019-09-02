
include Basic

attr_accessor :email

format :html do
  view :setup, unknown: true, perms: ->(_fmt) { Auth.needs_setup? } do
    with_nest_mode :edit do
      voo.title = "Your deck is ready to go!" # LOCALIZE
      voo.show! :help
      voo.hide! :menu
      voo.help = haml :setup_help
      Auth.as_bot { setup_form }
    end
  end

  def setup_form
    frame_and_form :create do
      [
        setup_hidden_fields,
        _render_name_formgroup,
        account_formgroup,
        setup_form_buttons
      ]
    end
  end

  def setup_form_buttons
    button_formgroup { setup_button }
  end

  def account_formgroup
    account = card.fetch trait: :account, new: {}
    subformat(account)._render :content_formgroups, structure: true
  end

  def setup_button
    submit_button text: "Set up", disable_with: "Setting up"
  end

  def setup_hidden_fields
    hidden_tags(
      setup: true,
      success: "REDIRECT: #{path mark: ''}",
      "card[type_id]" => Card.default_accounted_type_id
    )
  end
end

def setup?
  Card::Env.params[:setup]
end

event :setup_as_bot, before: :check_permissions, on: :create, when: :setup? do
  abort :failure unless Auth.needs_setup?
  Auth.as_bot
  # we need bot authority to set the initial administrator roles
  # this is granted and inspected here as a separate event for
  # flexibility and security when configuring initial setups
end

event :setup_first_user, :prepare_to_store, on: :create, when: :setup? do
  add_subcard "signup alert email+*to", content: name
  add_subfield :roles, content: roles_for_first_user
end

def roles_for_first_user
  %i[help_desk shark administrator].map(&:cardname)
end

event :signin_after_setup, :integrate, on: :create, when: :setup? do
  Auth.signin id
end
