$(window).ready ->
  $("body").on "change", "._filter-input input, ._filter-input select, ._filter-sort", ->
    filterAndSort this

  $("body").on "click", "._filter-category-select", ->
    addFilterDropdown = $(this).closest("._add-filter-dropdown")
    category = $(this).data("category")
    label = $(this).data("label")
    filterCategorySelected(addFilterDropdown, category, label)

  $("body").on "click", "._delete-filter-input", ->
    form = $(this).closest("._filter-form")
    input = $(this).closest("._filter-input")
    category = input.data("category")

    addCategoryOption(form, category)
    hideFilterInputField(input)
    form.submit()

  $("body").on "click", "._filter-items ._unselected ._search-checkbox-item input", ->
    selectFilteredItem $(this)
    updateAfterSelection $(this)

  $("body").on "click", "._filter-items ._selected ._search-checkbox-item input", ->
    bin = selectedBin $(this)
    $(this).slot().remove()
    updateAfterSelection bin

  $("body").on "click", "._filter-items ._add-selected", ->
    btn = $(this)
    content = newFilteredListContent btn
    btn.attr "href", addSelectedButtonUrl(btn, content)

  $("body").on "click", "._select-all", ->
    filterBox($(this)).find("._unselected ._search-checkbox-item input").each ->
      selectFilteredItem $(this)
    $(this).prop "checked", false
    updateAfterSelection $(this)

  $("body").on "click", "._deselect-all", ->
    filterBox($(this)).find("._selected ._search-checkbox-item input").each ->
      $(this).slot().remove()
    $(this).prop "checked", true
    updateAfterSelection $(this)

  $('body').on 'click', '._filtered-list-item-delete', ->
    $(this).closest('li').remove()

newFilteredListContent = (el) ->
  decko.pointerContent prefilteredNames(el).concat(selectedNames el)

addSelectedButtonUrl = (btn, content) ->
  view = btn.slot().data("slot")["view"]
  card_args = { content: content, type: "Pointer" }
  query = { assign: true, view: view, card: card_args }
  url_base = decko.rootPath + btn.attr("href") + "&" + $.param(query)
  decko.prepUrl url_base, btn.slot()

updateAfterSelection = (el) ->
  trackSelectedIds el
  filterAndSort filterBox(el).find "._filter-form"
  updateSelectedCount el
  updateUnselectedCount el

updateSelectedCount = (el) ->
  count = selectedBin(el).children().length
  filterBox(el).find("._selected-items").html count
  deselectAllLink(el).attr "disabled", count == 0
  addSelectedButton(el).attr "disabled", count == 0
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

prefilteredIds = (el) ->
  prefilteredData el, "cardId"

prefilteredNames = (el) ->
  prefilteredData el, "cardName"

prefilteredData = (el, field) ->
  btn = addSelectedButton el
  selector = btn.data "itemSelector"
  arrayFromField btn.slot().find(selector), field

# this button contains the data about the form that opened the filter-items interface.
# the itemSelector
addSelectedButton = (el) ->
  filterBox(el).find("._add-selected")

deselectAllLink = (el) ->
  filterBox(el).find("._deselect-all")

selectedIds = (el) ->
  selectedData el, "cardId"

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

filterCategorySelected = (addFilterDropdown, selectedCategory, label) ->
  widget = addFilterDropdown.closest("._filter-widget")
  removeCategoryOption(addFilterDropdown, selectedCategory)
  showFilterInputField(selectedCategory, widget)

showFilterInputField = (category, widget) ->
  selector = "._filter-input-field-prototypes > ._filter-input-field.#{category} > .input-group"
  $inputField = $(widget.find(selector)[0])

  $(widget.find("._add-filter-dropdown")).before($inputField)
  setFilterInputWidth $inputField
  decko.initAutoCardPlete($inputField.find("input")) # only has effect if there is a data-options-card value
  $inputField.find("input, select").focus()

setFilterInputWidth = ($inputField) ->
  # multiple select fields are skipped because it the importance filter on wikirate
  # with preselected options got too much height because of this
  $inputField.find("select:not([multiple])").select2(
    dropdownAutoWidth: "true"
  )

hideFilterInputField = (input) ->
  widget = input.closest("._filter-widget")
  category = input.data("category")
  $hiddenInputSlot = $(widget.find("._filter-input-field-prototypes > ._filter-input-field.#{category}")[0])
  $hiddenInputSlot.append input

addCategoryOption = (form, option) ->
  form.find("._filter-category-select[data-category='#{option}']").show()

removeCategoryOption = (el, option) ->
  el.find("._filter-category-select[data-category='#{option}']").hide()

filterAndSort = (el)->
  form = $(el).closest("._filter-form")
  form.submit()

