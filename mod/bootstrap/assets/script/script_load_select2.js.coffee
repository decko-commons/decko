$.fn.select2.defaults.set("theme", "bootstrap-5")

decko.slot.ready (slot) ->
  slot.find('select:not(._no-select2):not(._select2autocomplete)').each (_i) ->
    decko.initSelect2($(this))

decko.slot.destroy (slot) ->
  slot.find('select:not(._no-select2)').each (_i) ->
    $(this).deInitSelect2()

$.extend decko,
  initSelect2: (elem) ->
    if elem.length == 0
      return
    else if elem.length > 1
      decko.initSelect2($(single_el)) for single_el in elem
    else
      opts = {
        dropdownAutoWidth: "true",
        containerCssClass: ":all:",
        width: "auto"}

      elem.attr "id", decko.uniqSelect2Id(elem.attr("id"))

      if elem.hasClass("tags")
        opts.tags = "true"
      if elem.data("placeholder")
        opts.placeholder = elem.data("placeholder")
      if elem.data("minimum-results-for-search")?
        opts.minimumResultsForSearch = elem.data("minimum-results-for-search")
      elem.select2(opts)

  uniqSelect2Id: (id) ->
    return id unless $("[data-select2-id=" + id + "]").length > 0
    decko.uniqSelect2Id id + "1"


$(window).ready ->
  $('body').on 'select2:select', '._go-to-selected', ->
    val = $(this).val()
    if val != ''
      window.location = decko.path(escape(val))

  $('body').on "select2:select", "._submit-on-select", (event) ->
      $(event.target).closest('form').submit()

$.fn.extend
  cloneSelect2: (withDataAndEvents, deepWithDataAndEvents) ->
    $old = if this.is('select') then this else this.find('select')
    $old.deInitSelect2()
    $cloned = this.clone(withDataAndEvents, deepWithDataAndEvents)
    decko.initSelect2 $old
    if $cloned.is('select')
      decko.initSelect2 $cloned
    else
      decko.initSelect2 $cloned.find('select')
    $cloned

  deInitSelect2: ->
    return unless @attr "data-select2-id"
    @select2 "destroy"
    @removeAttr "data-select2-id"
    @find("option").removeAttr "data-select2-id"
