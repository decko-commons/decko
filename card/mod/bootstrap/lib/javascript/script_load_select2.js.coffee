decko.slotReady (slot) ->
  slot.find('select:not(._no-select2)').each (i) ->
    $(this).select2()

$.fn.select2.defaults.set( "theme", "bootstrap" )

#  slot.find('.pointer-multiselect').each (i) ->
#    load_select2($(this))
#
#  slot.find('.pointer-select').each (i) ->
#    load_select2($(this))
