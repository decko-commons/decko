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
    process = @_process
    decko.select2Autocomplete.init el, @_options(),
      processResults: (data) ->
        results: process(data)
      data: (params) ->
        query: { keyword: params.term }
        view: "image_complete"


  _options: (_el) ->
    minimumInputLength: 1
    templateResult: @_templateResult
    templateSelection: @_templateSelection

  _templateResult: (i) ->
    return i.text if i.loading or !i.icon
    i.icon + '<span class="search-box-item-value ml-1">' + i.text + '</span>'

  _templateSelection: (i) ->
    return i.text unless i.icon
    '<span class="search-box-item-value ml-1">' + i.text + '</span>'

  _process: (response) ->
    items = []
    $.each response['result'], (index, val) ->
      i = decko.imageComplete._imageItem(id: val[0], icon: val[1], text: val[0])
      items.push i

    items

  _imageItem: (data) ->
    data.id ||= data.prefix
    data.icon ||= data.prefix
    data.label ||= '<strong class="highlight">' + data.text + '</strong>'
    data


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
