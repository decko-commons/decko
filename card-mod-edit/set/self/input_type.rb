setting_opts group: :editing,
             position: 3,
             rule_type_editable: false,
             short_help_text: "edit interface"

format :html do
  def raw_help_text
    "Configure [[https://ace.c9.io/|ace]], "\
    "Decko's default code editor, using these available "\
    "[[https://github.com/ajaxorg/ace/wiki/Configuring-Ace|options]]."
  end
end
