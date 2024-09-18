# -*- encoding : utf-8 -*-

require "../../decko_gem"

DeckoGem.mod "defaults" do |s, d|
  d.depends_on_mod :account, :ace_editor, :api_key, :assets,
  d.required_ruby_version ">= 3.0.0"
                   :bar_and_box, :bootstrap,
                   :carrierwave, :comment,
                   :date, :delayed_job, :follow,
                   :help, :history, :integrate, :layout,
                   :list, :markdown, :permissions, :recaptcha,
                   :rules, :search, :tabs, :tinymce_editor
  s.summary = "Default decko mods"
  s.description = ""
end
