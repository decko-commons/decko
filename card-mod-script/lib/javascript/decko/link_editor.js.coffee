$(document).ready ->
  $('body').on 'click', 'button._link-apply', () ->
    link.applyLink($(this).data("tinymce-id"), $(this).data("tm-snippet-start"), $(this).data("tm-snippet-size"))

window.link ||= {}

$(document).ready ->
  $('body').on 'click', '._link-field-toggle', () ->
    if $(this).is(':checked')
      link.addPlus()
    else
      link.removePlus()

  $('body').on 'input', 'input._link-target', (event) ->
    link.targetChanged()

  $('body').on 'input', 'input._link-title', (event) ->
    link.titleChanged()

$.extend link,
  # called by TinyMCE
  openLinkEditor: (tm) ->
    params = nest.editParams(tm, "[[", "]]") unless params?
    nest.openEditorForTm(tm, params, "link_editor", "modal_link_editor")

  applyLink: (tinymce_id, link_start, link_size) ->
    nest.applySnippet("link", tinymce_id, link_start, link_size)

  target: () ->
    link.evalFieldOption $('input._link-target').val()

  title: () ->
    $('input._link-title').val()

  titleChanged: () ->
    new_val = $("._link-preview").val().replace(/^\[\[[^\]]*/, "[[" + link.target() + "|" + link.title())
    link.updatePreview new_val

  targetChanged: () ->
    new_val = $("._link-preview").val().replace(/^\[\[[^\]|]*/, "[[" + link.target())
    link.updatePreview new_val

  evalFieldOption: (name) ->
    if link.isField() then "+#{name}" else name

  isField: ->
    $('._link-field-toggle').is(":checked")

  addPlus: () ->
    new_val = $("._link-preview").val().replace(/^\[\[\+?/, "[[+")
    link.updatePreview new_val
    $(".input-group.hide-prefix").removeClass("hide-prefix").addClass("show-prefix")

  removePlus: () ->
    new_val = $("._link-preview").val().replace(/^\[\[\+?/, "[[")
    link.updatePreview new_val
    $(".input-group.show-prefix").removeClass("show-prefix").addClass("hide-prefix")

  updatePreview: (new_val) ->
    new_val = "[[#{link.target()}|#{link.title()}]]" unless new_val?
    $("._link-preview").val new_val
