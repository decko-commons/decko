$(window).ready ->
  $('body').on "change", "._filter-input input, ._filter-input select, ._filter-sort", ->
    filterAndSort this

  $('body').on "click", "._filter-category-select", ->
    addFilterDropdown = $(this).closest("._add-filter-dropdown")
    category = $(this).data("category")
    label = $(this).data("label")
    filterCategorySelected(addFilterDropdown, category, label)

  $('body').on "click", "._delete-filter-input", ->
    form = $(this).closest("._filter-form")
    input = $(this).closest("._filter-input")
    category = input.data("category")

    addCategoryOption(form, category)
    hideFilterInputField(input)
    form.submit()

filterCategorySelected = (addFilterDropdown, selectedCategory, label) ->
  widget = addFilterDropdown.closest("._filter-widget")

  removeCategoryOption(addFilterDropdown, selectedCategory)
  showFilterInputField(selectedCategory, widget)


showFilterInputField = (category, widget) ->
  $searchInputField = $(widget.find("._filter-input-field-prototypes > ._filter-input-field.#{category} > .input-group")[0])

  $(widget.find("._add-filter-dropdown")).before($searchInputField)
  # multiple select fields are skipped because it the importance filter on wikirate
  # with preselected options got too much height because of this
  $searchInputField.find('select:not([multiple])').select2(
    dropdownAutoWidth: "true"
  )
  $searchInputField.find("input, select").focus()

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