include_set Abstract::Accountable

attr_accessor :email

format :html do
  delegate :needs_setup?, to: Card::Auth

  view :setup, unknown: true, perms: :needs_setup? do
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
        account_formgroups,
        setup_form_buttons
      ]
    end
  end

  def setup_form_buttons
    button_formgroup { setup_button }
  end

  def setup_button
    submit_button text: "Set up", disable_with: "Setting up"
  end

  def setup_hidden_fields
    hidden_tags(
      setup: true,
      success: { redirect: true, mark: path(mark: "") },
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
  subcard %i[signup_alert_email to].cardname, content: name
  roles_for_first_user.each do |role|
    subcard [role, :members], content: name
  end
end

def roles_for_first_user
  %i[help_desk shark administrator].map(&:cardname)
end

event :signin_after_setup, :integrate, on: :create, when: :setup? do
  Auth.signin id
end
