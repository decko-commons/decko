# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "defaults" do |s, d|
  d.depends_on_mod :account, :ace_editor, :api_key, :bar_and_box, :bootstrap,
                   :carrierwave, :comment, :date, :delayed_job, :follow,
                   :help, :history, :integrate, :layout,
                   :list, :machines, :markdown, :permissions,
                   :prosemirror_editor, :recaptcha, :rules, :search, :tinymce_editor,
                   :alias, :legacy, :google_analytics, # temporarily!
  s.summary = "Default decko mods"
  s.description = ""
end
