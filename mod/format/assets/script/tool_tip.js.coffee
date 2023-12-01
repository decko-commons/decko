$ ->
  cardMenu = $('.card-menu.nodblclick')

  cardMenu.on 'mouseover', ->
    $(this).css '--tooltip-opacity', '1'

  cardMenu.on 'mouseout', ->
    $(this).css '--tooltip-opacity', '0'