decko.slotReady (slot) ->
  slot.find('._disappear').delay(5000).animate(
    height: 0, 1000, -> $(this).hide())

  if slot.hasClass("_refresh-timer")
    setTimeout(
      -> slot.reloadSlot(slot.data("refresh-url")),
      2000
    )



