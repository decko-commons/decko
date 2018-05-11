# -*- encoding : utf-8 -*-

class AddDatepicker < Card::Migration::Core
  HELP_TEXT = <<-TEXT.strip_heredoc
    Configure the date select tool using these available [[https://tempusdominus.github.io/bootstrap-4/Options/|options]]
  TEXT

  DEFAULT_CONFIG = <<-TEXT.strip_heredoc
    {
      "format": "YY-MM-DD",
      "useCurrent": true,
      "defaultDate": false
    }
  TEXT

  def up
    ensure_card "Date", codename: "date", type_id: Card::CardtypeID
    ensure_card "script: datepicker",
                codename: "script_datepicker", type_id: Card::JavaScriptID
    ensure_card "style: datepicker",
                codename: "style_datepicker", type_id: Card::ScssID
    ensure_card "script: datepicker config",
                codename: "script_datepicker_config", type_id: Card::CoffeeScriptID
    ensure_card "*datepicker",
                codename: "datepicker", type_id: Card::JsonID,
                content: DEFAULT_CONFIG
    ensure_card %i[datepicker self help], content: HELP_TEXT
  end
end
