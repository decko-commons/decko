format :html do
  view :server_error, template: :haml

  view :debug_server_error, wrap: { modal: { size: :full } } do
    error_page = BetterErrors::ErrorPage.new Card::Error.current,
                                             "PATH_INFO" => request.env["REQUEST_URI"]
    haml :debug_server_error, {}, error_page
  end

  view :unknown do
    createable { wrap { unknown_link "#{unknown_icon} #{render_title}" } }
  end

  # icon only, no wrap
  view :mini_unknown, unknown: true, cache: :never do
    createable { unknown_link unknown_icon }
  end

  def createable
    card.ok?(:create) ? yield : ""
  end

  def unknown_link text
    link_to_view :new_in_modal, text,
                 path: (voo.type ? { card: { type: voo.type } } : {}),
                 class: classy("unknown-link")
  end

  def unknown_icon
    fa_icon "plus-square"
  end

  view :compact_missing, perms: :none do
    wrap_with :span, h(title_in_context), class: "text-muted"
  end

  view :conflict, cache: :never do
    actor_link = link_to_card card.last_action.act.actor.name
    class_up "card-slot", "error-view"
    wrap do # LOCALIZE
      alert "warning" do
        %(
          <strong>Conflict!</strong>
          <span class="new-current-revision-id">#{card.last_action_id}</span>
          <div>#{actor_link} has also been making changes.</div>
          <div>Please examine below, resolve above, and re-submit.</div>
          #{render_act}
        )
      end
    end
  end

  view :errors, perms: :none do
    return if card.errors.empty?

    voo.title = if card.name.blank?
                  "Problems"
                else
                  t(:format_problems_name,
                    cardname: card.name)
                end
    voo.hide! :menu
    class_up "alert", "card-error-msg"
    standard_errors voo.title
  end

  view :not_found, cache: :never do
    voo.hide! :menu
    voo.title = "Not Found"
    frame do
      [not_found_errors, sign_in_or_up_links("to create it")]
    end
  end

  view :denial do
    focal? ? loud_denial : quiet_denial
  end

  def view_for_unknown setting_view
    main? && ok?(:create) ? :new : super
  end

  def show_all_errors?
    # make configurable by env
    Auth.always_ok? || Rails.env.development?
  end

  def error_cardname exception
    cardname = super
    show_all_errors? ? backtrace_link(cardname, exception) : cardname
  end

  def rendering_error exception, view
    wrap_with(:span, class: "render-error alert alert-danger") { super }
  end

  def error_modal_id
    @error_modal_id ||= unique_id
  end

  def error_message exception
    %{
      <h3>Error message (visible to admin only)</h3>
      <p><strong>#{CGI.escapeHTML exception.message}</strong></p>
      <div>#{exception.backtrace * "<br>\n"}</div>
    }
  end

  def backtrace_link cardname, exception
    # TODO: make this a modal link after new modal handling is merged in
    wrap_with(:span, title: error_message(exception)) { cardname }
  end

  def standard_errors heading=nil
    alert "warning", true do
      [
        (wrap_with(:h4, heading, class: "alert-heading error") if heading),
        error_messages.join("<hr>")
      ]
    end
  end

  def simple_error_message message
    h message
  end

  def standard_error_message error
    "<p><strong>#{h error.attribute.to_s.upcase}:</strong> #{h error.message}</p>"
  end

  def not_found_errors
    if card.errors.any?
      standard_errors
    else
      haml :not_found
    end
  end

  def sign_in_or_up_links to_task
    return if Auth.signed_in?

    links = [signin_link, signup_link].compact.join " #{t(:format_or)} "
    wrap_with(:div) do
      "#{[t(:format_please), links, to_task].join(' ')}."
    end
  end

  def signin_link
    link_to_card :signin, t(:account_sign_in)&.downcase,
                 class: "signin-link", slotter: true, path: { view: :open }
  end

  def signup_link
    return unless signup_ok?

    link_to_card :signup, t(:account_sign_up)&.downcase,
                 class: "signup-link", slotter: true, path: { action: :new }
  end

  def signup_ok?
    Card.new(type_id: Card::SignupID).ok? :create
  end

  def quiet_denial
    wrap_with :span, class: "denied" do
      "<!-- Sorry, you don't have permission (#{@denied_task}) -->"
    end
  end

  def loud_denial
    voo.hide :menu
    frame do
      [wrap_with(:h1, t(:format_sorry)),
       wrap_with(:div, loud_denial_message)]
    end
  end

  def loud_denial_message
    to_task = if @denied_task
                t(:format_denied_task,
                  denied_task: @denied_task)
              else
                t(:format_to_do_that)
              end

    case
    when not_denied_task_read?
      t(:format_read_only)
    when Auth.signed_in?
      t(:format_need_permission_task, task: to_task)
    else
      Env.save_interrupted_action request.env["REQUEST_URI"]
      sign_in_or_up_links to_do_unauthorized_task
    end
  end

  def not_denied_task_read?
    @denied_task != :read && Card.config.read_only
  end

  def to_do_unauthorized_task
    if @denied_task
      t(:format_denied_task,
        denied_task: @denied_task)
    else
      t(:format_to_do_that)
    end
  end
end
