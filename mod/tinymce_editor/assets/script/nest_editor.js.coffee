$(document).ready ->
  $('body').on 'click', 'button._nest-apply', () ->
    if $(this).data("index")?
      nest.applyNestToNestListEditor($(this).data("index"))
    else
      nest.applyNestToTinymceEditor($(this).data("tinymce-id"), $(this).data("tm-snippet-start"), $(this).data("tm-snippet-size"))

  $('body').on 'click', 'button._image_nest-apply', () ->
    nest.applyNestToTinymceEditor($(this).data("tinymce-id"), $(this).data("tm-snippet-start"), $(this).data("tm-snippet-size"))

  $('body').on 'click', 'button._change-create-to-update', () ->
    tm_id = $(this).closest("form").find("#success_tinymce_id").val()
    nest.changeCreateToUpdate(tm_id)

  $('body').on 'click', 'button._open-nest-editor', () ->
    form = $(this).closest("._nest-form")
    reference = form.find("._reference").val()
    nest_options = form.find("._nest-options").val()
    encoded_nest = encodeURIComponent "{{#{reference}|#{nest_options}}}"
    nest.openNestEditorForSlot(
      $(this).closest(".card-slot"),
      $(this).closest(".slotter"),
      "index=#{form.data('index')}&tm_snippet_raw=#{encoded_nest}"
    )

window.nest ||= {}

$.extend nest,
  # called by TinyMCE
  openNestEditor: (tm, params) ->
    params = nest.editParams(tm) unless params?
    this.openEditorForTm(tm, params, "nest_editor", "modal_nest_editor")

  openNestEditorForSlot: (slot, slotter, params) ->
    card = if slot[0] then $(slot[0]).attr('data-card-name') else ":update"
    nest.request(card, "nest_editor", "modal_nest_editor", slotter, params)

  openEditorForTm: (tm, params, overlay_view, modal_view) ->
    params += "&tinymce_id=#{tm.id}"
    slot = $("##{tm.id}").closest(".card-slot")
    editor = $("##{tm.id}").closest(".card-editor")
    slotter = $("##{tm.id}")

    card = (editor[0] and $(editor[0]).attr('card_name')) or
           (slot[0] and $(slot[0]).attr('data-card-name')) or ":update"
    if card.length == 0
      card = ":update"
    nest.request(card, overlay_view, modal_view, slotter, params)

  # called by TinyMCE
  openImageEditor: (tm) ->
    params = nest.editParams(tm, "{{", "}}", false) unless params?
    this.openEditorForTm(tm, params,"nest_image", "modal_nest_image")

  changeCreateToUpdate: (tm_id) ->
    form = $("##{tm_id}").closest("form")
    new_action = form.attr("action").replace("card/create", "card/update")
    form.attr("action", new_action)

  insertNest: (tm, nest_string) ->
    tm.insertContent(nest_string)
    # insertIndex = nest.offsetAfterInsert(tm, nest_string)
    # params = nest.paramsStr(insertIndex, nest_string)
    # nest.openNestEditor(etm, params)


  request: (card, overlay_view, modal_view, slotter, params) ->
    slot = $(".board-sidebar > ._overlay-container-placeholder > .card-slot")

    if false #slot[0]
      view = overlay_view
      mode = "overlay"
    else
      slot = $($(".card-slot")[0])
      view = modal_view
      mode = "modal"

    nest.sendRequest(slotter, slot, mode, card, view, params)

  sendRequest: (slotter, slot, mode, card, view, params) ->
      params = "" unless params?
      url = "/#{card}?view=#{view}&#{params}"
      $.ajax
        url: url
        success: (html) ->
          slot.slotContent html, mode, slotter

  editParams: (tm, prefix="{{", postfix="}}", edit=true) ->
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
      if edit
        nest.paramsStr(nest_start, name)
      else
        nest.paramsStr(nest_start + nest_size)
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
    offset - content.lengthr

  applyNestToTinymceEditor: (tinymce_id, nest_start, nest_size) ->
    nest.applySnippet("nest", tinymce_id, nest_start, nest_size)

  applyNestToNestListEditor: (index) ->
    row = $("._nest-form[data-index='#{index}']")
    row.find("._reference").val(nest.name())
    row.find("._nest-options").val(nest.options())
    decko.updateAddItemButton(row)

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
    new_val = "{{ #{nest.name()}|#{nest.options()} }}" unless new_val?
    preview = $("._nest-preview")
    preview.val new_val
    preview.data("nest-options", nest.options())
    preview.data("reference", nest.name())
