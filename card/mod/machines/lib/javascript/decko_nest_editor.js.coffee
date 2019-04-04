$(document).ready ->
  $('body').on 'click', 'button._nest-apply', () ->
    nest.apply($(this).data("tinymce-id"), $(this).data("nest-start"), $(this).data("nest-size"))

window.nest ||= {}

$.extend nest,
  openEditor: (tm) ->
    nest.tmRequest(tm, ":update", "nest_editor", "modal_nest_editor", nest.editParams(tm))

  openImageEditor: (tm) ->
    card_name = $("##{tm.id}").closest(".card-slot").data("card-name")
    nest.tmRequest tm, "#{card_name}+image", "new", "new", "&type=image"

  tmRequest: (tm, card, overlay_view, modal_view, params) ->
    slot = $(".bridge-sidebar > ._overlay-container-placeholder > .card-slot")

    if slot[0]
      view = overlay_view
      mode = "overlay"
    else
      # FIXME get a slot
      view = modal_view
      mode = "modal"

    slotter = $("##{tm.id}")
    url = "/#{card}?view=#{view}&tinymce_id=#{tm.id}#{params}"

    $.ajax
      url: url
      type: 'GET'
      success: (html) ->
        slot.setSlotContent html, mode, slotter

  editParams: (tm) ->
    sel = tm.selection.getSel()
    return "&nest_start=0" unless sel? and sel.anchorNode?

    text = sel.anchorNode.data
    return "&nest_start=0" unless text

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
      nest_size = index.after.close + offset + 2 - nest_start
      nest = encodeURIComponent text.substr(nest_start, nest_size)
      "&nest_start=#{nest_start}&edit_nest=#{nest}"
    else
      "&nest_start=#{offset}"

  apply: (tinymce_id, nest_start, nest_size) ->
    content =  $("._nest-preview").val()
    editor = tinymce.get(tinymce_id)
    if nest_start?
     nest.replaceNest(editor, nest_start, nest_size, content)
     $('button._nest-apply').attr("data-nest-size", content.length)
    else
      editor.insertContent content

  replaceNest: (editor, nest_start, nest_size, content) ->
    node = editor.selection.getSel().anchorNode
    if node?
      text = node.data
      nest_size = 0 unless nest_size?
      text = "#{text.substr(0, nest_start)}#{content}#{text.substr(nest_start + nest_size)}"
      node.data = text
    else
      editor.insertContent content

  updatePreview: (new_val) ->
    new_val = "{{#{nest.name()}|#{nest.options()}}}" unless new_val?
    $("._nest-preview").val new_val
