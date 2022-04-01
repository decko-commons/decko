decko.slotReady (slot) ->
  $('[data-bs-toggle="popover"]').popover(html: true)
  $('.colorpicker-component').colorpicker()