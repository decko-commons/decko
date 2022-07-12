$(window).ready ->
  $('body').on 'show.bs.popover', '._card-menu-popover', () ->
    $(this).closest(".card-menu._show-on-hover")
           .removeClass("_show-on-hover")
           .addClass("_show-on-hover-disabled")

  $('body').on 'hide.bs.popover', '._card-menu-popover', () ->
    $(this).closest(".card-menu._show-on-hover-disabled")
           .removeClass("_show-on-hover-disabled")
           .addClass("_show-on-hover")


decko.slot.ready (slot) ->
  slot.find('[data-tooltip="true"]').tooltip()
  slot.find('[data-bs-toggle="popover"]').popover(html: true)
