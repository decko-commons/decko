$.fn.select2.defaults.set("theme", "bootstrap")

decko.slotReady (slot) ->
  slot.find('select:not(._no-select2)').each (_i) ->
    decko.initSelect2($(this))

$.extend decko,
  initSelect2: (elem) ->
    if elem.length > 1
      decko.initSelect2($(single_el)) for single_el in elem
    else
      opts = { dropdownAutoWidth: "true", containerCssClass: ":all:", width: "auto" }
      if elem.hasClass("tags")
        opts.tags = "true"
      if elem.data("minimum-results-for-search")?
        opts.minimumResultsForSearch = elem.data("minimum-results-for-search")
      elem.select2(opts)

$(window).ready ->
  $('body').on 'select2:select', '._go-to-selected', ->
    val = $(this).val()
    if val != ''
      window.location = decko.path(escape(val))

  $('body').on "select2:select", "._submit-on-select", (event) ->
      $(event.target).closest('form').submit()

$.fn.cloneSelect2 = (withDataAndEvents, deepWithDataAndEvents) ->
  $old = if this.is('select') then this else this.find('select')
  $old.select2 'destroy'
  $old.removeAttr "data-select2-id"
  $cloned = this.clone(withDataAndEvents, deepWithDataAndEvents)
  decko.initSelect2 $old
  if $cloned.is('select')
    decko.initSelect2 $cloned
  else
    decko.initSelect2 $cloned.find('select')
  $cloned


#  slot.find('.pointer-multiselect').each (i) ->
#    load_select2($(this))
#
#  slot.find('.pointer-select').each (i) ->
#    load_select2($(this))
