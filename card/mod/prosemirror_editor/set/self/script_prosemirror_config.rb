include_set Abstract::CodeFile

Self::ScriptEditors.add_item :script_prosemirror_config
All::Head::HtmlFormat.add_to_basket :mod_js_config,
                                    [:prose_mirror, "setProseMirrorConfig"]
