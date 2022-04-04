# filter object that manages dynamic sorting and filtering

# el can be any element inside widget
decko.filter = (el) ->
  closest_widget = $(el).closest "._filter-widget"
  @widget =
    if closest_widget.length
      closest_widget
    else
      $(el).closest("._filtered-content").find "._filter-widget"


  # the filter form includes the below
  @form = @widget.find "._filter-form"

  # one-click filter links
  @quickFilter = @widget.find "._quick-filter"

  # include filters field, more-fields dropdown, and reset button
  @activeContainer = @widget.find "._filter-container"

  # the "More Filters" Dropdown
  @dropdown = @widget.find "._add-filter-dropdown"
  @dropdownItems = @widget.find "._filter-category-select"

  @showWithStatus = (status) ->
    f = this
    $.each (@dropdownItems), ->
      item = $(this)
      if item.data status
        f.activate item.data("category")

  @reset = () ->
    @restrict @form.find("._reset-filter").data("reset")

  @clear = () ->
    @dropdownItems.show()
    @activeContainer.find(".input-group").remove()

  @activate = (category, value) ->
    @activateField category, value
    @hideOption category

  @showOption = (category) ->
    @dropdown.show()
    @option(category).show()

  @hideOption = (category) ->
    @option(category).hide()
    @dropdown.hide() if @dropdownItems.length <= @activeFields().length

  @activeFields = () ->
    @activeContainer.find "._filter-input"

  @option = (category) ->
    @dropdownItems.filter("[data-category='#{category}']")

  @findPrototype = (category) ->
    @widget.find "._filter-input-field-prototypes ._filter-input-#{category}"

  @activateField = (category, value) ->
    field = @findPrototype(category).clone()
    @fieldValue field, value
    @dropdown.before field
    @initField field
    field.find("input, select").first().focus()

  @fieldValue = (field, value) ->
    if typeof(value) == "object" && !Array.isArray(value)
      @compoundFieldValue field, value
    else
      @simpleFieldValue field, value

  @simpleFieldValue = (field, value) ->
    input = field.find("input, select")
    input.val value if (typeof value != 'undefined')

  @compoundFieldValue = (field, vals) ->
    for key of vals
      input = field.find "#filter_value_" + key
      input.val vals[key]

  @removeField = (category)->
    @activeField(category).remove()
    @showOption category

  @initField = (field) ->
    @initSelectField field
    decko.initAutoCardPlete field.find("input")
    # only has effect if there is a data-options-card value

  @initSelectField = (field) ->
    decko.initSelect2(field.find("select"))

  @activeField = (category) ->
    @activeContainer.find("._filter-input-#{category}")

  @isActive = (category) ->
    @activeField(category).length

  # clear filter and use restrictions in data
  @restrict = (data) ->
    @clear()
    for key of data
      @activateField key, data[key]
    @update()

  @addRestrictions = (hash) ->
    for category of hash
      @removeField category
      @activate category, hash[category]
    @update()

  @removeRestrictions = (hash) ->
    for category of hash
      @removeField category
    @update()

  # triggers update
  @setInputVal = (field, value) ->
    select = field.find "select"
    if select.length
      @setSelect2Val select, value
    else
      @setTextInputVal field.find("input"), value

  # this triggers change, which updates form
  # if we just use simple "val", the display doesn't update correctly
  @setSelect2Val = (select, value) ->
    value = [value] if select.attr("multiple") && !Array.isArray(value)
    select.select2.val(value)

  @setTextInputVal = (input, value) ->
    input.val value
    @update()

  @updateLastVals = ()->
    @activeFields().find("input, select").each ()->
      $(this).data "lastVal", $(this).val()

  @updateUrlBar = () ->
    return if @widget.closest('._noFilterUrlUpdates')[0]
    window.history.pushState "filter", "filter", '?' + @form.serialize()

  @update = ()->
    @updateLastVals()
    @updateQuickLinks()
    @form.submit()
    @updateUrlBar()

  @updateQuickLinks = ()->
    widget = this
    links = @quickFilter.find "._filter-link"
    links.addClass "active"
    links.each ->
      link = $(this)
      opts = link.data "filter"
      for key of opts
        widget.deactivateQuickLink link, key, opts[key]

  @deactivateQuickLink = (link, key, value) ->
    sel = "._filter-input-#{key}"
    $.map [@form.find("#{sel} input, #{sel} select").val()], (arr) ->
      arr = [arr].flat()
      link.removeClass "active" if $.inArray(value, arr) > -1

  @updateIfChanged = ()->
    @update() if @changedSinceLastVal()

  @updateIfPresent = (category)->
    val = @activeField(category).find("input, select").val()
    @update() if val && val.length > 0

  @changedSinceLastVal = () ->
    changed = false
    @activeFields().find("input, select").each ()->
      changed = true if $(this).val() != $(this).data("lastVal")
    changed

  this
