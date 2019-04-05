$(document).ready ->
  $('body').on 'click', 'button._nest-apply', () ->
    nest.apply($(this).data("tinymce-id"), $(this).data("nest-start"), $(this).data("nest-size"))

window.nest ||= {}

$.extend nest,
  openEditor: (tm, params) ->
    params = nest.editParams(tm) unless params?

    nest.tmRequest(tm, ":update", "nest_editor", "modal_nest_editor", params)

  openImageEditor: (tm) ->
    slot = $("##{tm.id}").closest(".card-slot")
    card_name = slot.data("card-name")
    nest.sendTmRequest(tm, slot, "modal", card_name, "nest_image")

  insertNest: (tm, nest) ->
    tm.insertContent(nest)
    params = nest.paramsStr(nest.offsetAfterInsert(tm, nest), nest)
    nest.openEditor(tm, params)

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

  editParams: (tm) ->
    sel = tm.selection.getSel()
    return nest.paramsStr(0) unless sel? and sel.anchorNode?

    text = sel.anchorNode.data
    return nest.paramsStr(sel.anchorOffset) unless text

    offset = sel.anchorOffset
    before = text.substr(0, offset)
    after =  text.substr(offset)
    index = {
      before: {
        close: before.lastIndexOf("}}")
        open: before.lastIndexOf("{{")
      },
      after: {
        close: after.indexOf("}}")
        open: after.indexOf("{{")
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
      params += "&nest_start=#{start}"
    if name? and name.length > 0
      params += "&edit_nest=#{encodeURIComponent(name)}"

    params

  apply: (tinymce_id, nest_start, nest_size) ->
    content =  $("._nest-preview").val()
    editor = tinymce.get(tinymce_id)
    if nest_start?
     nest.replaceNest(editor, nest_start, nest_size, content)
    else
      editor.insertContent content
      offset = nest.offsetAfterInsert(editor, content)
      $('button._nest-apply').attr("data-nest-start", offset)

    $('button._nest-apply').attr("data-nest-size", content.length)

  offsetAfterInsert: (editor, content) ->
    offset = editor.selection.getSel().anchorOffset
    offset - content.length

  replaceNest: (editor, nest_start, nest_size, content) ->
    sel = editor.selection.getSel()
    if sel? and sel.anchorNode? and sel.anchorNode.data?
      text = sel.anchorNode.data
      nest_size = 0 unless nest_size?
      text = "#{text.substr(0, nest_start)}#{content}#{text.substr(nest_start + nest_size)}"
      sel.anchorNode.data = text
    else
      editor.insertContent content

  updatePreview: (new_val) ->
    new_val = "{{#{nest.name()}|#{nest.options()}}}" unless new_val?
    $("._nest-preview").val new_val
