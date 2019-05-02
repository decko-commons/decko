decko.addEditor(
  '.ace-editor-textarea',
  ->
    decko.initAce $(this),
  ->
    aceEditorContent this[0]
)

$.extend decko,
  setAceConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    decko.aceConfig = setter()

  configAceEditor: (editor, mode) ->
    conf = {
      showGutter: true,
      theme: "ace/theme/github",
      printMargin: false,
      tabSize: 2,
      useSoftTabs: true,
      maxLines: 30
    }
    hard_conf = {
      mode: "ace/mode/" + mode
    }
    user_conf = if decko.aceConfig? then decko.aceConfig else {}
    $.extend conf, user_conf['default'], user_conf[mode], hard_conf
    editor.setOptions conf

  initAce: (textarea) ->
    mode = textarea.attr "data-ace-mode"

    unless mode
      textarea.autosize()
      return
    editDiv = $("<div>",
      position: "absolute"
      width: "auto"
      height: textarea.height()
    ).insertBefore(textarea)
    textarea.css "visibility", "hidden"
    textarea.css "height", "0px"
    ace.config.set('basePath', decko.path('assets/ace_editor/ace'))
    editor = ace.edit(editDiv[0])
    editor.getSession().setValue textarea.val()
    decko.configAceEditor(editor, mode)
    return

aceEditorContent = (element) ->
  ace_div = $(element).siblings(".ace_editor")
  editor = ace.edit(ace_div[0])
  editor.getSession().getValue()
