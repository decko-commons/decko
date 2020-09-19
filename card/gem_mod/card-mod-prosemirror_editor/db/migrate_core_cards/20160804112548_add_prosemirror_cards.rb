# -*- encoding : utf-8 -*-

class AddProsemirrorCards < Card::Migration
  PM_CONFIG = <<-JSON.strip_heredoc
                {
                  "menuBar": true,
                  "tooltipMenu": false
                }
              JSON
  def up
    ensure_card name: "*ProseMirror", type_id: Card::PlainTextID,
                codename: "prose_mirror",
                content: PM_CONFIG
    create_or_update name: "*ProseMirrorz+*self+*help", content: pm_help
    ensure_card name: "script: prosemirror", type_id: Card::JavaScriptID,
                codename: "script_prosemirror"
    ensure_card name: "style: prosemirror", type_id: Card::ScssID,
                codename: "style_prosemirror"
    ensure_card name: "script: prosemirror config",
                type_id: Card::CoffeeScriptID,
                codename: "script_prosemirror_config"
  end

  def pm_help
    "Configure [[http://prosemirror.net|ProseMirror]], "\
    "Decko's default "\
    "[[http://en.wikipedia.org/wiki/Wysiwyg|wysiwyg]] editor. "\
    "[[https://decko.org/ProseMirror|more]]"
  end
end
