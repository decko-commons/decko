decko.slotReady (slot) ->
  slot.find("._filter-widget").each ->
    if slot[0] == $(this).slot()[0]
      filter = new decko.filter this
      filter.showWithStatus "active"
      filter.updateLastVals()
      filter.updateQuickLinks()

$(window).ready ->
  filterFor = (el) ->
    new decko.filter el

  # sometimes this element shows up as changed and breaks the filter.
  weirdoSelect2FilterBreaker = (el) ->
    $(el).hasClass "select2-search__field"

  filterableData = (filterable) ->
    f = $(filterable)
    f.data("filter") || f.find("._filterable").data("filter")

  targetFilter = (filterable) ->
    selector = $(filterable).closest("._filtering").data("filter-selector")
    filterFor (selector || this)

  # Add Filter
  $("body").on "click", "._filter-category-select", (e) ->
    e.preventDefault()
    # e.stopPropagation()
    f = filterFor(this)
    category = $(this).data("category")
    f.activate category
    f.updateIfPresent category

  # Update filter results based on filter value changes
  onchangers =
    "._filter-input input:not(.simple-text), ._filter-input select, ._filter-sort"
  $("body").on "change", onchangers, ->
    return if weirdoSelect2FilterBreaker this
    filterFor(this).update()

  # update filter result after typing in text box
  keyupTimeout = null
  $("body").on "keyup", "._filter-input input.simple-text", ->
    clearTimeout keyupTimeout
    filter = filterFor this
    keyupTimeout = setTimeout ( -> filter.updateIfChanged() ), 333

  # remove filter
  $("body").on "click", "._delete-filter-input", ->
    filter = filterFor this
    filter.removeField $(this).closest("._filter-input").data("category")
    filter.update()

  # reset all filters
  $('body').on 'click', '._reset-filter', () ->
    f = filterFor(this)
    f.reset()
    f.update()

  $('body').on 'click', '._filtering ._filterable', (e) ->
    f = targetFilter this
    if f.widget.length
      f.restrict filterableData(this)
      e.preventDefault()
      e.stopPropagation()

  $('body').on 'click', '._filter-link', (e) ->
    f = filterFor this
    link = $(this)
    filter_data = link.data "filter"
    if inactiveQuickfilter link
      f.removeRestrictions filter_data
    else
      f.addRestrictions filter_data

    e.preventDefault()
    e.stopPropagation()

  inactiveQuickfilter = (link) ->
    !link.hasClass("active") && link.closest(".quick-filter").length > 0

