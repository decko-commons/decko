format :html do
  def raw_help_text
    # LOCALIZE
    "Register your domain at Google's [[http://google.com/recaptcha|reCAPTCHA service]] "\
    "and enter your site key and secret key below.<br>"\
    "If you want to turn catchas off then change all [[*captcha|captcha rules]] to 'no'."
  end

  # def instructions title, steps
  #   steps = list_tag steps, ordered: true
  #   "#{title}#{steps}"
  # end
  #
  #       <h5>#{instructions}</h5>
  #       #{howto_add_new_recaptcha_keys}
  #       #{howto_turn_captcha_off}
  #
  # def howto_add_new_recaptcha_keys
  #   instructions(
  #     I18n.t(:howto_add_keys, scope: "mod.admin.set.self.admin_info"),
  #     [
  #       I18n.t(:howto_register,
  #              scope: "mod.admin.set.self.admin_info",
  #              recaptcha_link: link_to_resource("http://google.com/recaptcha")),
  #       I18n.t(:howto_add,
  #              scope: "mod.admin.set.self.admin_info",
  #              recaptcha_settings: link_to_card(:recaptcha_settings))
  #     ]
  #   )
  # end
  #
  # def howto_turn_captcha_off
  #   instructions(
  #     I18n.t(:howto_turn_off, scope: "mod.admin.set.self.admin_info"),
  #     [
  #       I18n.t(:howto_go,
  #              scope: "mod.admin.set.self.admin_info",
  #              captcha_card: link_to_card(:captcha)),
  #       I18n.t(:howto_update,
  #              scope: "mod.admin.set.self.admin_info")
  #     ]
  #   )
  # end
end
