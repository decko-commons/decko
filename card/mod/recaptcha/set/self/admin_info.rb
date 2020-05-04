add_to_basket :warnings, :recaptcha_config_issues

def recaptcha_config_issues?
  RecaptchaCard.using_defaults?
end

format :html do
  def recaptcha_config_issues_message
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
    link_text = I18n.t :recaptcha_keys, scope: "mod.admin.set.self.admin_info"
    Card[:recaptcha_settings]&.format&.edit_link link_text: link_text
  end
end
