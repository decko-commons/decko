decko.slotReady (slot) ->
  $('[data-toggle="popover"]').popover(html: true)
  $('.colorpicker-component').colorpicker()