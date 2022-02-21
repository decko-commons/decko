$(window).ready ->
  $('body').on  "change", '._live-type-field', ->
    $this = $(this)

    setSlotMode($this)
    $this.data 'params', $this.closest('form').serialize()
    $this.data 'url', $this.attr 'href'

  $('body').on 'change', '.edit-type-field', ->
    $(this).closest('form').submit()

setSlotMode = ($el, mode=null) ->
  $slotter =  $el.closest(".slotter")
  if $slotter.length
    if $slotter.attr('data-slotter-mode')
      $slotter.attr 'data-original-slotter-mode', $slotter.attr('data-slotter-mode')
      $slotter.attr 'data-slotter-mode', mode
    if $slotter.attr('data-slot-selector')
      $slotter.attr 'data-original-slot-selector', $slotter.attr('data-slot-selector')
      $slotter.removeAttr 'data-slot-selector'
