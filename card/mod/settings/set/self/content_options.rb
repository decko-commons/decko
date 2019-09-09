extend Card::Setting
setting_opts group: :editing, position: 1,
             restricted_to_type: %i[pointer session],
             rule_type_editable: true,
             help_text: "Value options for [[Pointer]] cards. Can itself be a Pointer "\
                        "or a [[Search]]. [[http://decko.org/Pointer|more]]"
