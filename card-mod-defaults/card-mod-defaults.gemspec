# -*- encoding : utf-8 -*-

require "../decko_gem"

DeckoGem.mod "defaults" do |s, d|
  d.depends_on_mod :account, :ace_editor, :api_key, :bar_and_box, :bootstrap,
                   :carrierwave, :comment, :date, :delayed_job, :follow,
                   :help, :history, :integrate, :layout,
                   :list, :machines, :markdown, :permissions, :recaptcha,
                   :rules, :search, :tinymce_editor,
                   # expecting to move following out of defaults:
                   :alias, :google_analytics, :legacy, :prosemirror_editor
  s.summary = "Default decko mods"
  s.description = ""
end
