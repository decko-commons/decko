decko.addEditor(
  '.prosemirror-editor',
  ->
    decko.initProseMirror @[0].id,
  ->
    prosemirrorContent @[0].id
)

$.extend decko,
  setProseMirrorConfig: (string) ->
    setter = ->
      try
        $.parseJSON string
      catch
        {}
    decko.proseMirrorConfig = setter()

  initProseMirror: (el_id) ->
    conf = {
      menuBar: true,
      tooltipMenu: false
    }
    hard_conf = { docFormat: "html" }
    user_conf = if decko.proseMirrorConfig? then decko.proseMirrorConfig else {}
    $.extend conf, user_conf, hard_conf
    createProseMirror(el_id, conf)

prosemirrorContent = (id) ->
  content = getProseMirrorContent(id)
  return '' if content == '<p></p>'
  content
