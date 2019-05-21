# FILTERED LIST / ITEMS INTERFACE
# (fancy pointer ui)

$(window).ready ->
# add all selected items
  $("body").on "click", "._filter-items ._add-selected", ->
    btn = $(this)
    content = newFilteredListContent btn
    btn.attr "href", addSelectedButtonUrl(btn, content)

  # select all visible filtered items
  $("body").on "click", "._select-all", ->
    filterBox($(this)).find("._unselected ._search-checkbox-item input").each ->
      selectFilteredItem $(this)
    $(this).prop "checked", false
    updateAfterSelection $(this)

  # deselect all selected items
  $("body").on "click", "._deselect-all", ->
    filterBox($(this)).find("._selected ._search-checkbox-item input").each ->
      $(this).slot().remove()
    $(this).prop "checked", true
    updateAfterSelection $(this)

  $("body").on "click", "._filter-items ._unselected ._search-checkbox-item input", ->
    selectFilteredItem $(this)
    updateAfterSelection $(this)

  $("body").on "click", "._filter-items ._selected ._search-checkbox-item input", ->
    bin = selectedBin $(this)
    $(this).slot().remove()
    updateAfterSelection bin

  $('body').on 'click', '._filtered-list-item-delete', ->
    $(this).closest('li').remove()

# TODO: make this object oriented!

newFilteredListContent = (el) ->
  $.map(prefilteredIds(el).concat(selectedIds el), (id) -> "~" + id).join "\n"

addSelectedButtonUrl = (btn, content) ->
  view = btn.slot().data("slot")["view"]
  card_args = { content: content, type: "Pointer" }
  query = { assign: true, view: view, card: card_args }
  path_base = btn.attr("href") + "&" + $.param(query)
  decko.slotPath path_base, btn.slot()

updateAfterSelection = (el) ->
  trackSelectedIds el
  f = new decko.filter(filterBox(el).find('._filter-widget'))
  f.update()
  updateSelectedCount el
  updateUnselectedCount el

updateSelectedCount = (el) ->
  count = selectedBin(el).children().length
  filterBox(el).find("._selected-items").html count
  deselectAllLink(el).attr "disabled", count == 0
  if count > 0
    addSelectedButton(el).removeClass("disabled")
  else
    addSelectedButton(el).addClass("disabled")

  updateSelectedSectionVisibility el, count > 0

updateSelectedSectionVisibility = (el, items_present) ->
  box = filterBox el
  selected_items = box.find "._selected-item-list"
  help_text = box.find "._filter-help"
  if items_present
    selected_items.show()
    help_text.hide()
  else
    selected_items.hide()
    help_text.show()

updateUnselectedCount = (el) ->
  box = filterBox(el)
  count = box.find("._search-checkbox-list").children().length
  box.find("._unselected-items").html count
  box.find("._select-all").attr "disabled", count > 0

selectFilteredItem = (checkbox) ->
  checkbox.prop "checked", true
  selectedBin(checkbox).append checkbox.slot()

selectedBin = (el) ->
  filterBox(el).find "._selected-bin"

filterBox = (el) ->
  el.closest "._filter-items"

# this button contains the data about the form that opened the filter-items interface.
# the itemSelector
addSelectedButton = (el) ->
  filterBox(el).find("._add-selected")

deselectAllLink = (el) ->
  filterBox(el).find("._deselect-all")

selectedIds = (el) ->
  selectedData el, "cardId"

prefilteredIds = (el) ->
  prefilteredData el, "cardId"

prefilteredNames = (el) ->
  prefilteredData el, "cardName"

prefilteredData = (el, field) ->
  btn = addSelectedButton el
  selector = btn.data "itemSelector"
  arrayFromField btn.slot().find(selector), field

selectedNames = (el) ->
  selectedData el, "cardName"

selectedData = (el, field) ->
  arrayFromField selectedBin(el).children(), field

arrayFromField = (rows, field) ->
  rows.map( -> $(this).data field ).toArray()

trackSelectedIds = (el) ->
  ids = prefilteredIds(el).concat selectedIds(el)
  box = filterBox el
  box.find("._not-ids").val ids.toString()
