
window.decko ||= {} #needed to run w/o *head.  eg. jasmine

# $.extend decko,
# Can't get this to work yet.  Intent was to tighten up head tag.
#  initGoogleAnalytics: (key) ->
#    window._gaq.push ['_setAccount', key]
#    window._gaq.push ['_trackPageview']
#
#    initfunc = ()->
#      ga = document.createElement 'script'
#      ga.type = 'text/javascript'
#      ga.async = true
#      ga.src = `('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js'`
#      s = document.getElementsByTagName('script')[0]
#      s.parentNode.insertBefore ga, s
#  initfunc()

$(window).ready ->
  $(document).on 'click', '._stop_propagation', (event)->
    event.stopPropagation()

  $(document).on 'click', '._prevent_default', (event)->
    event.preventDefault()

  $('body').on 'mouseenter', 'a[data-hover-text]', ->
    text = $(this).text()
    $(this).data("original-text", text)
    $(this).text($(this).data("hover-text"))

  $('body').on 'mouseleave', 'a[data-hover-text]', ->
    $(this).text($(this).data("original-text"))

  #decko_org mod (for now)
  $('body').on 'click', '.shade-view h1', ->
    toggleThis = $(this).slot().find('.shade-content').is ':hidden'
    decko.toggleShade $(this).closest('.pointer-list').find('.shade-content:visible').parent()
    if toggleThis
      decko.toggleShade $(this).slot()

  if firstShade = $('.shade-view h1')[0]
    $(firstShade).trigger 'click'

  # performance log mod
  $('body').on 'click', '.open-slow-items', ->
    panel = $(this).closest('.panel-group')
    panel.find('.open-slow-items').removeClass('open-slow-items').addClass('close-slow-items')
    panel.find('.toggle-fast-items').text("show < 100ms")
    panel.find('.duration-ok').hide()
    panel.find('.panel-danger > .panel-collapse').collapse('show').find('a > span').addClass('show-fast-items')

  $('body').on 'click', '.close-slow-items', ->
    panel = $(this).closest('.panel-group')
    panel.find('.close-slow-items').removeClass('close-slow-items').addClass('open-slow-items')
    panel.find('.toggle-fast-items').text("hide < 100ms")
    panel.find('.panel-danger > .panel-collapse').collapse('hide').removeClass('show-fast-items')
    panel.find('.duration-ok').show()

  $('body').on 'click', '.toggle-fast-items', ->
    panel = $(this).closest('.panel-group')
    if $(this).text() == 'hide < 100ms'
      panel.find('.duration-ok').hide()
      $(this).text("show < 100ms")
    else
      panel.find('.duration-ok').show()
      $(this).text("hide < 100ms")

  $('body').on 'click', '.show-fast-items', (event) ->
    $(this).removeClass('show-fast-items')
    panel = $(this).closest('.panel-group')
    panel.find('.duration-ok').show()
    panel.find('.show-fast-items').removeClass('show-fast-items')
    panel.find('.panel-collapse').collapse('show')
    event.stopPropagation()

$.extend decko,
  toggleShade: (shadeSlot) ->
    shadeSlot.find('.shade-content').slideToggle 1000
    shadeSlot.find('.glyphicon').toggleClass 'glyphicon-triangle-right glpyphicon-triangle-bottom'
