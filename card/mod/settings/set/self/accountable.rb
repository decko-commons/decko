require_dependency "card/setting"
extend Card::Setting
setting_opts group: :other, position: 2,
             help_text: "[[http://decko.org/custom_help_text|Help text]] people will "\
                        "see when editing."
