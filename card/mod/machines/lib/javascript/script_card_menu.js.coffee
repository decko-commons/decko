decko.slotReady (slot) ->
  if decko.isTouchDevice()
    slot.find('._show-on-hover').removeClass('_show-on-hover')
