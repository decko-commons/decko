$(document).ready ->
  $('body').on 'click', 'button._nest-apply', () ->
    nest.applyNest($(this).data("tinymce-id"), $(this).data("tm-snippet-start"), $(this).data("tm-snippet-size"))

window.nest ||= {}

$.extend nest,
  # called by TinyMCE
  openNestEditor: (tm, params) ->
    params = nest.editParams(tm) unless params?

    slot = $("##{tm.id}").closest(".card-slot")
    card = if slot[0] then $(slot[0]).attr('data-card-name') else ":update"
    nest.tmRequest(tm, card, "nest_editor", "modal_nest_editor", params)

  # called by TinyMCE
  openImageEditor: (tm) ->
    slot = $("##{tm.id}").closest(".card-slot")
    card_name = slot.data("card-name")
    nest.tmRequest(tm, card_name, "nest_image", "modal_nest_image")

  insertNest: (tm, nest_string) ->
    tm.insertContent(nest_string)
    # insertIndex = nest.offsetAfterInsert(tm, nest_string)
    # params = nest.paramsStr(insertIndex, nest_string)
    # nest.openNestEditor(etm, params)

  tmRequest: (tm, card, overlay_view, modal_view, params) ->
    slot = $(".bridge-sidebar > ._overlay-container-placeholder > .card-slot")

    if slot[0]
      view = overlay_view
      mode = "overlay"
    else
      # FIXME get a slot
      slot = $($(".card-slot")[0])
      view = modal_view
      mode = "modal"

    nest.sendTmRequest(tm, slot, mode, card, view, params)

  sendTmRequest: (tm, slot, mode, card, view, params) ->
    slotter = $("##{tm.id}")
    params = "" unless params?
    url = "/#{card}?view=#{view}&tinymce_id=#{tm.id}#{params}"

    $.ajax
      url: url
      type: 'GET'
      success: (html) ->
        slot.setSlotContent html, mode, slotter

  editParams: (tm, prefix="{{", postfix="}}") ->
    sel = tm.selection.getSel()
    return nest.paramsStr(0) unless sel? and sel.anchorNode?

    text = sel.anchorNode.data
    return nest.paramsStr(sel.anchorOffset) unless text

    offset = sel.anchorOffset
    before = text.substr(0, offset)
    after =  text.substr(offset)
    index = {
      before: {
        close: before.lastIndexOf(postfix)
        open: before.lastIndexOf(prefix)
      },
      after: {
        close: after.indexOf(postfix)
        open: after.indexOf(prefix)
      }
    }
    if index.before.open > index.before.close &&
       index.after.close != -1 &&
       (index.after.open == -1 || index.after.close < index.after.open)
      nest_start = index.before.open
      unless name?
        nest_size = index.after.close + offset + 2 - nest_start
        name = text.substr(nest_start, nest_size)
      nest.paramsStr(nest_start, name)
    else
      nest.paramsStr(offset)

  paramsStr: (start, name) ->
    params = ""
    if start?
      params += "&tm_snippet_start=#{start}"
    if name? and name.length > 0
      params += "&tm_snippet_raw=#{encodeURIComponent(name)}"

    params

  offsetAfterInsert: (editor, content) ->
    offset = editor.selection.getSel().anchorOffset
    offset - content.length

  applyNest: (tinymce_id, nest_start, nest_size) ->
    nest.applySnippet("nest", tinymce_id, nest_start, nest_size)

  applySnippet: (snippet_type, tinymce_id, start, size) ->
    content = $("._#{snippet_type}-preview").val()
    editor = tinymce.get(tinymce_id)
    if start?
      nest.replaceSnippet(editor, start, size, content)
    else
      editor.insertContent content
      offset = nest.offsetAfterInsert(editor, content)
      $("button._#{snippet_type}-apply").attr("data-tm-snippet-start", offset)

    $("button._#{snippet_type}-apply").attr("data-tm-snippet-size", content.length)

  replaceSnippet: (editor, start, size, content) ->
    sel = editor.selection.getSel()
    if sel? and sel.anchorNode? and sel.anchorNode.data?
      text = sel.anchorNode.data
      size = 0 unless size?
      text = "#{text.substr(0, start)}#{content}#{text.substr(start + size)}"
      sel.anchorNode.data = text
    else
      editor.insertContent content

  updatePreview: (new_val) ->
    new_val = "{{#{nest.name()}|#{nest.options()}}}" unless new_val?
    $("._nest-preview").val new_val
