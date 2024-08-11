include_set Abstract::AccountHolder

basket[:roles_for_first_user] = %i[help_desk shark administrator]

attr_accessor :email

format :html do
  delegate :needs_setup?, to: Card::Auth

  view :setup, unknown: true, perms: :needs_setup?, cache: :never do
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
      card: {
        type_id: Card.default_accounted_type_id,
        trigger: %w[check_setup]
      },
      success: { redirect: true, mark: path(mark: "") }
    )
  end
end

event :check_setup, before: :check_permissions, on: :create, trigger: :required do
  abort :failure unless Auth.needs_setup?
  Auth.as_bot
  @setup_approved = true
  # we need bot authority to set the initial administrator roles
  # this is granted and inspected here as a separate event for
  # flexibility and security when configuring initial setups
end

event :setup_first_user, :finalize, on: :create, when: :setup? do
  subcard %i[signup_alert_email to].cardname, content: name
  basket[:roles_for_first_user].map(&:cardname).each do |role|
    subcard [role, :members].cardname, content: name
  end
end

event :signin_after_setup, :integrate, on: :create, when: :setup? do
  Auth.signin id
end

private

def setup?
  @setup_approved == true
end
