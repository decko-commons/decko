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

  $("body").on "click", ".filter-items .unselected .search-checkbox-item input", ->
    selectFilteredItem $(this)
    updateFilterAfterSelection $(this)

  $("body").on "click", ".filter-items .selected .search-checkbox-item input", ->
    bin = selectedBin $(this)
    $(this).slot().remove()
    updateFilterAfterSelection bin

  $("body").on "click", ".filter-items .add-selected", ->
    btn = $(this)
    content = newFilteredListContent btn
    btn.attr "href", addSelectedButtonUrl(btn, content)

newFilteredListContent = (el) ->
  oldContent = el.slot().find(".d0-card-content").val()
  newContent = decko.pointerContent selectedNames(el)
  return newContent if !oldContent
  oldContent + "\n" + newContent

addSelectedButtonUrl = (btn, content) ->
  view = btn.slot().data("slot")["view"]
  query = { "card[content]" : content, "assign" : true, "view" : view }
  url_base = btn.attr("href") + "?" + $.param(query)
  decko.prepUrl url_base, btn.slot()

updateFilterAfterSelection = (el) ->
  trackSelectedIds el
  filterAndSort filterBox(el).find "._filter-form"

selectFilteredItem = (checkbox) ->
  checkbox.prop "checked", true
  selectedBin(checkbox).append checkbox.slot()

selectedBin = (el) ->
  filterBox(el).find ".selected-bin"

filterBox = (el) ->
  el.closest ".filter-items"

selectedIds = (el) ->
  selectedData el, "cardId"

selectedNames = (el) ->
  selectedData el, "cardName"

selectedData = (el, field) ->
  slots = selectedBin(el).children()
  slots.map( -> $(this).data field ).toArray()

trackSelectedIds = (el) ->
  ids = selectedIds el
  box = filterBox el
  box.find(".not-ids").val ids.toString()
  box.find(".add-selected").attr "disabled", ids.length == 0

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