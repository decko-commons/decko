#decko.slotReady (slot) ->
#  slot.find("._filter-widget").each ->
#    showDefaultFilters $(this)

$.extend decko,
  filterCategorySelected: ($selected_item) ->
    category = $selected_item.data("category")
    widget = $selected_item.closest("._filter-widget")
    activateFilterCategory(category, widget)

decko.slotReady (slot) ->
  slot.find("._filter-widget").each ->
    if slot[0] == $(this).slot()[0]
      showDefaultFilters($(this))

$(window).ready ->
  # Add Filter
  $("body").on "click", "._filter-category-select", (e) ->
    e.preventDefault()
    e.stopPropagation()
    decko.filterCategorySelected($(this))

  # Update filter results based on filter value changes
  onchangers = "._filter-input input:not(.simple-text), " +
    "._filter-input select, ._filter-sort"
  $("body").on "change", onchangers, ->
    return if weirdoSelect2FilterBreaker this
    filterAndSort this

  keyupTimeout = null
  $("body").on "keyup", "._filter-input input.simple-text", ->
    clearTimeout keyupTimeout
    text_input = this
    keyupTimeout = setTimeout ( -> filterAndSort text_input ), 333

  # remove filter
  $("body").on "click", "._delete-filter-input", ->
    form = $(this).closest("._filter-form")
    input = $(this).closest("._filter-input")
    category = input.data("category")

    addCategoryOption(form, category)
    input.remove()
    form.submit()

  # reset all filters
  $('body').on 'click', '._reset-filter', (e) ->
    resetFilter $(this).closest("._filter-widget")
    e.preventDefault()
    e.stopPropagation()

showDefaultFilters = (widget) ->
  $.each (widget.find "._filter-category-select"), ->
    item = $(this)
    if item.data("default")
      activateFilterCategory item.data("category"), widget

resetFilter = (widget) ->
  container = widget.find "._filter-container"
  container.find(".input-group").remove()
  showDefaultFilters widget
  filterAndSort container

# sometimes this element shows up as changed and breaks the filter.
weirdoSelect2FilterBreaker = (el) ->
  $(el).hasClass "select2-search__field"

activateFilterCategory = (category, widget) ->
  dropdown = widget.find "._add-filter-dropdown"
  removeCategoryOption dropdown, category
  activateFilterInputField category, widget, dropdown

findFilterInputPrototype = (category, widget) ->
  selector = "._filter-input-field-prototypes" +
             " > ._filter-input-field.#{category}" +
             " > .input-group"
  $(widget.find(selector)[0])

activateFilterInputField = (category, widget, dropdown) ->
  filterInput = findFilterInputPrototype(category, widget).clone()
  dropdown.before filterInput
  initFilterInput filterInput
  filterInput.find("input, select").first().focus()

initFilterInput = (filterInput) ->
  setFilterInputWidth filterInput
  decko.initAutoCardPlete filterInput.find("input")
  # only has effect if there is a data-options-card value

setFilterInputWidth = (filterInput) ->
  filterInput.find("select").select2(
    containerCssClass: ":all:"
    width: "auto"
    dropdownAutoWidth: "true"
  )

addCategoryOption = (form, option) ->
  form.find("._filter-category-select[data-category='#{option}']").show()

removeCategoryOption = (el, option) ->
  el.find("._filter-category-select[data-category='#{option}']").hide()

filterAndSort = (el)->
  form = $(el).closest("._filter-form")
  form.submit()

