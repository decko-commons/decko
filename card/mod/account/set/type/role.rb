
format :html do
  view :link_with_checkbox do
    role_checkbox
  end

  def role_checkbox
    card_form :update, recaptcha: :off do
      [check_box_tag("", :disable, true, class: "_submit-on-change"),
       render_link]
    end
  end

  def submit_checkbox text, url

  end
end
