decko.slot.ready (slot) ->
  sdata = slot.data("slot")
  if sdata? && sdata["show"]? && sdata["show"].includes "preview_redirect"
    tabPanel = slot.closest(".tab-panel")
    tabPanel.find(".tab-li-preview a").tab("show")
    nest.updateImagePreview(slot)

  if slot.hasClass("modal_nest_image-view")
    imageSelect = slot.find('._image-card-select')
    if imageSelect.length > 0
      decko.imageComplete.init imageSelect
      nest.updateImageName(slot.find(".new_image-view .new_fields-view .submit-button"))

$(document).ready ->
  $('body').on 'select2:select', '._image-name', () ->
    nest.updateImagePreview(this)

  $('body').on 'select2:select', '._image-view-select', () ->
    nest.updateImagePreview(this)

  $('body').on 'select2:select', '._image-size-select', () ->
    nest.updateImagePreview(this)

  $('body').on 'click', ".new_image-view .new_fields-view .submit-button", ->
    nest.updateImageName($(this))


decko.imageComplete =
  init: (el) ->
    decko.select2Autocomplete.init el, @_options(el),
      data: (params) ->
        query: { keyword: params.term }
        view: "image_complete"

  _options: (el) ->
    dropdownParent: el.parent()

window.nest ||= {}

$.extend nest,
  updateImageName: (container) ->
    name = container.slot().data("cardName");
    nameSelect = container.closest(".tab-content").find("._image-name")
    option = new Option(name, name, true, true);
    nameSelect.append(option)
    nameSelect.val(name)
    nameSelect.trigger('change')

  updateImagePreview: (el) ->
    tabs = $(el).closest(".tab-content")
    name = tabs.find("._image-name").val();
    view = tabs.find("._image-view-select").val();
    size = tabs.find("._image-size-select").val();
    syntaxPreview = tabs.closest("._nest-editor").find("._nest-preview")
    syntaxPreview.val("{{ #{name} | view: #{view}; size: #{size} }}")

    slot = tabs.find(".tab-pane-preview > .card-slot");
    path = "#{name}?view=#{view}&size=#{size}"
    $(slot).slotReload path
