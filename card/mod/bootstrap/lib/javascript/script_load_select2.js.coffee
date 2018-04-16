decko.slotReady (slot) ->
  slot.find('select:not(._no-select2)').each (i) ->
    opts = { containerCssClass: ":all:", dropdownAutoWidth: "true" }
    if $(this).hasClass("tags")
      opts.tags = "true"
    $(this).select2(opts)

  # TODO: move to better place
  $('.colorpicker-component').colorpicker()


$.fn.select2.defaults.set("theme", "bootstrap")


#  slot.find('.pointer-multiselect').each (i) ->
#    load_select2($(this))
#
#  slot.find('.pointer-select').each (i) ->
#    load_select2($(this))
