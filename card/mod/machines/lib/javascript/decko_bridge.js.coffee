decko.slotReady (slot, slotter) ->
  slot.updateBridge(false, slotter)

  links = slot.find('ul._auto-single-select > li.nav-item > a.nav-link')
  if links.length == 1
    $(links[0]).click()

#  $('#mark').on "select2:select", (e) ->
#    navboxSelect(e)
$(window).ready ->



