#decko.slotReady (slot) ->
#  slot.find("._filter-widget").each ->
#    showDefaultFilters $(this)

decko.slotReady (slot) ->
  slot.find("._filter-widget").each ->
    if slot[0] == $(this).slot()[0]
      filter = new decko.filter this
      filter.showWithStatus "active"

$(window).ready ->
  filterFor = (el) ->
    new decko.filter el

  # Add Filter
  $("body").on "click", "._filter-category-select", (e) ->
    e.preventDefault()
    e.stopPropagation()
    filterFor(this).activate $(this).data("category")

  # Update filter results based on filter value changes
  onchangers = "._filter-input input:not(.simple-text), " +
    "._filter-input select, ._filter-sort"
  $("body").on "change", onchangers, ->
    return if weirdoSelect2FilterBreaker this
    filterFor(this).update()

  keyupTimeout = null
  $("body").on "keyup", "._filter-input input.simple-text", ->
    clearTimeout keyupTimeout
    filter = filterFor this
    keyupTimeout = setTimeout ( -> filter.update() ), 333

  # remove filter
  $("body").on "click", "._delete-filter-input", ->
    filter = filterFor this
    filter.removeInput this
    filter.update()

  # reset all filters
  $('body').on 'click', '._reset-filter', (e) ->
    filterFor(this).reset()
    e.preventDefault()
    e.stopPropagation()

# sometimes this element shows up as changed and breaks the filter.
weirdoSelect2FilterBreaker = (el) ->
  $(el).hasClass "select2-search__field"

# el can be any element inside widget
decko.filter = (el) ->
  @widget = $(el).closest "._filter-widget"
  @activeContainer = @widget.find "._filter-container"
  @dropdown = @widget.find "._add-filter-dropdown"
  @dropdownItems = @widget.find "._filter-category-select"

  @showWithStatus = (status) ->
    f = this
    $.each (@dropdownItems), ->
      item = $(this)
      if item.data status
        f.activate item.data("category")

  @reset = () ->
    @activeContainer.find(".input-group").remove()
    @showWithStatus "default"
    @update()

  @activate = (category) ->
    @hideOption category
    @activateInput category

  @showOption = (category) ->
    @option(category).show()

  @hideOption = (category) ->
    @option(category).hide()

  @option = (category) ->
    @dropdownItems.filter("[data-category='#{category}']")

  @findPrototype = (category) ->
    @widget.find "._filter-input-field-prototypes ._filter-input-#{category}"

  @activateInput = (category) ->
    input = @findPrototype(category).clone()
    @dropdown.before input
    @initInput input
    input.find("input, select").first().focus()

  @removeInput = (input)->
    input = $(input).closest "._filter-input"
    @showOption input.data("category")
    input.remove()

  @initInput = (input) ->
    @initSelectInput input
    decko.initAutoCardPlete input.find("input")
    # only has effect if there is a data-options-card value

  @initSelectInput = (input) ->
    input.find("select").select2(
      containerCssClass: ":all:"
      width: "auto"
      dropdownAutoWidth: "true"
    )

  @activeInput = (category) ->
    @activeContainer.find("._filter-input-#{category}")

  @isActive = (category) ->
    @activeInput(category).length > 0

  @restrict = (category, value) ->
    @activateInput category unless @isActive category
    input = @activeInput category
    input.find("input, select").val value

  @update = ()->
    @widget.find("._filter-form").submit()

  this
