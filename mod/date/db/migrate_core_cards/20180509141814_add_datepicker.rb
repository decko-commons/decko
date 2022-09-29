# -*- encoding : utf-8 -*-

class AddDatepicker < Cardio::Migration::Core
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
    Card.ensure name: "Date", codename: "date", type_id: Card::CardtypeID
    Card.ensure name: "script: datepicker",
                codename: "script_datepicker", type_id: Card::JavaScriptID
    Card.ensure name: "style: datepicker",
                codename: "style_datepicker", type_id: Card::ScssID
    Card.ensure name: "script: datepicker config",
                codename: "script_datepicker_config", type_id: Card::CoffeeScriptID
    Card.ensure name: "*datepicker",
                codename: "datepicker", type_id: Card::JsonID,
                content: DEFAULT_CONFIG
    Card.ensure name: %i[datepicker self help], content: HELP_TEXT
  end
end
