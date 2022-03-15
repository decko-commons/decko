formatImageCardItem = (i) ->
  if i.loading
    return i.text
  i.icon + '<span class="navbox-item-value ml-1">' + i.text + '</span>'


formatImageCardSelectedItem = (i) ->
  unless i.icon
    return i.text
  '<span class="navbox-item-value ml-1">' + i.text + '</span>'

prepareImageItems = (response) ->
  items = []
  $.each response['result'], (index, val) ->
    i = imageItem(id: val[0], icon: val[1], text: val[0])
    items.push i

  items

imageItem = (data) ->
  data.id ||= data.prefix
  data.icon ||= data.prefix
  data.label ||= '<strong class="highlight">' + data.text + '</strong>'
  data

decko.slotReady (slot) ->
  slotData = slot.data("slot")
  if slotData? && slotData["show"]? && slotData["show"].includes "preview_redirect"
    tabPanel = slot.closest(".tab-panel")
    tabPanel.find(".tab-li-preview a").tab("show")
    nest.updateImagePreview(slot)

  if slot.hasClass("modal_nest_image-view")
    imageSelect = slot.find('._image-card-select')
    if imageSelect.length > 0
      decko.initSelect2Autocomplete(imageSelect, "image_complete",
        prepareImageItems, formatImageCardItem, formatImageCardSelectedItem)
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
    $(slot).reloadSlot(path)