include_set Abstract::CodeFile

Self::ScriptEditors.add_item :script_tinymce_config
All::Head::HtmlFormat.add_to_basket :mod_js_config, [:tiny_mce, "setTinyMCEConfig"]
