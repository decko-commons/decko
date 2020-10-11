basket :warnings

# For each warning in the basket (eg :my_warning), the core view
# will run a test by appending a question mark (eg #my_warning?).
# If it fails it will generate a message by appending message
# (eg #my_warning_message).

add_to_basket :warnings, :no_email_delivery

def no_email_delivery?
  Cardio.config.action_mailer.perform_deliveries == false
end

def clean_html?
  false
end

format :html do
  view :core do
    warnings = card.warnings.map do |warning|
      card.send("#{warning}?") ? send("#{warning}_message") : nil
    end
    warnings.compact!
    warnings.empty? ? "" : warning_alert(warnings)
  end

  def warning_alert warnings
    admin_warn = I18n.t(:admin_warn, scope: "mod.admin.set.self.admin_info")
    # 'ADMINISTRATOR WARNING'
    alert :warning, true do
      "<h5>#{admin_warn}</h5>" + list_tag(warnings)
    end
  end

  def no_email_delivery_message
    # "Email delivery is turned off."
    # "Change settings in config/application.rb to send sign up notifications."
    I18n.t(:email_off,
           scope: "mod.admin.set.self.admin_info",
           path: "config/application.rb")
  end

  def warning_list_with_auto_scope warnings
    # 'ADMINISTRATOR WARNING'
    admin_warn = tr(:admin_warn)
    "<h5>#{admin_warn}</h5>" + warnings.join("\n")
  end
end
