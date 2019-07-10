def clean_html?
  false
end

format :html do
  view :core do
    warnings = []
    warnings << email_warning if Card.config.action_mailer.perform_deliveries == false
    if Card.config.recaptcha_public_key ==
       Card::Auth::Permissions::RECAPTCHA_DEFAULTS[:recaptcha_public_key] &&
       card.rule(:captcha) == "1"
      warnings << recaptcha_warning
    end
    return "" if warnings.empty?

    alert :warning, true do
      warning_list warnings
    end
  end

  def warning_list warnings
    # 'ADMINISTRATOR WARNING'
    admin_warn = I18n.t(:admin_warn, scope: "mod.admin.set.self.admin_info")
    "<h5>#{admin_warn}</h5>" + list_tag(warnings)
  end

  def warning_list_with_auto_scope warnings
    # 'ADMINISTRATOR WARNING'
    admin_warn = tr(:admin_warn)
    "<h5>#{admin_warn}</h5>" + warnings.join("\n")
  end

  def email_warning
    # "Email delivery is turned off."
    # "Change settings in config/application.rb to send sign up notifications."
    I18n.t(:email_off,
           scope: "mod.admin.set.self.admin_info",
           path: "config/application.rb")
  end

  def recaptcha_warning
    warning =
      if Card::Env.localhost?
        # %(Your captcha is currently working with temporary settings.
        #   This is fine for a local installation, but you will need new
        #   recaptcha keys if you want to make this site public.)
        I18n.t(:captcha_temp, scope: "mod.admin.set.self.admin_info",
                              recaptcha_link: add_recaptcha_keys_link)
      else
        # %(You are configured to use [[*captcha]], but for that to work
        #   you need new recaptcha keys.)
        I18n.t(:captcha_keys, scope: "mod.admin.set.self.admin_info",
                              recaptcha_link: add_recaptcha_keys_link,
                              captcha_link: link_to_card(:captcha))
      end
    <<-HTML
      <p>#{warning}</p>
    HTML
  end

  def add_recaptcha_keys_link
    nest :recaptcha_settings,
         view: :edit_link, title: I18n.t(:recaptcha_keys,
                                         scope: "mod.admin.set.self.admin_info")
  end
end
