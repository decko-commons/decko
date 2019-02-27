decko.slotReady (slot) ->
  menu = $(slot).find('.open-menu.dropdown-toggle')
  if menu?
    $(menu).dropdown('toggle')

  if decko.isTouchDevice()
    slot.find('._show-on-hover').removeClass('_show-on-hover')

$(window).ready ->
  $('body').on 'click', '.toolbar .nav-pills > li', ->
    $(this).tab('show')
