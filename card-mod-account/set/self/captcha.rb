extend Card::Setting
setting_opts group: :permission, position: 5,
             help_text: "Anti-spam setting.  Requires non-signed-in users to complete a "\
                        "[[http://decko.org/captcha|captcha]] before adding or editing "\
                        "cards (where permitted)."
