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

  $("body").on "click", ".filter-items .search-checkbox-item input", ->
    input = $(this)
    decko.boom = input
    input.prop "checked", true
    item = input.closest ".search-checkbox-item"
    filter_box = item.closest ".filter-items"
    bin = filter_box.find ".selected-bin"
    bin.append item
    # item.remove()



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
  $hiddenInputSlot.append(input)

addCategoryOption = (form, option) ->
  form.find("._filter-category-select[data-category='#{option}']").show()

removeCategoryOption = (el, option) ->
  el.find("._filter-category-select[data-category='#{option}']").hide()

filterAndSort = (el)->
    form = $(el).closest("._filter-form")
    form.submit()