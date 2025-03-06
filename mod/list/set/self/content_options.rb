setting_opts group: :editing, position: 5,
             restricted_to_type: %i[list pointer session],
             rule_type_editable: true,
             help_text: "Value options for [[List]] and [[Pointer]] and cards. " \
                        "Can itself be a List or a [[Search]]. " \
                        "[[http://decko.org/Pointer|more]]",
             applies: lambda { |prototype|
                        prototype.rule_card(:input_type).supports_content_options?
                      }
