$.extend decko,
  # returns absolute path (starting with a slash)
  # if rawPath is complete url, this returns the complete url
  # if rawPath is relative (no slash), this adds relative root
  path: (rawPath) ->
    if rawPath.match /^\/|:\/\//
      rawPath
    else
      decko.rootUrl + rawPath

  pingName: (name, success)->
    $.getJSON decko.path(''), format: 'json', view: 'status', 'card[name]': name, success

jQuery.fn.extend {
  notify: (message, status) ->
    slot = @slot(status)
    notice = slot.find '.card-notice'
    unless notice[0]
      notice = $('<div class="card-notice"></div>')
      form = slot.find('.card-form')
      if form[0]
        $(form[0]).append notice
      else
        slot.append notice
    notice.html message
    notice.show 'blind'

  report: (message) ->
    report = @slot().find '.card-report'
    return false unless report[0]
    report.hide()
    report.html message
    report.show 'drop', 750
    setTimeout (->report.hide 'drop', 750), 3000
}

#~~~~~ ( EVENTS )

$(window).ready ->
  $.ajaxSetup cache: false

  $('body').on 'click', '.submitter', ->
    $(this).closest('form').submit()

  $('body').on 'click', 'button.redirecter', ->
    window.location = $(this).attr('href')

  $('body').on 'change', '.live-type-field', ->
    $(this).data 'params', $(this).closest('form').serialize()
    $(this).data 'url', $(this).attr 'href'

  $('body').on 'change', '.edit-type-field', ->
    $(this).closest('form').submit()

  $('body').on 'mouseenter', '[hover_content]', ->
    $(this).attr 'hover_restore', $(this).html()
    $(this).html $(this).attr( 'hover_content' )
  $('body').on 'mouseleave', '[hover_content]', ->
    $(this).html $(this).attr( 'hover_restore' )

  $('body').on 'click', '.render-error-link', (event) ->
    msg = $(this).closest('.render-error').find '.render-error-message'
    msg.show()
#    msg.dialog()
    event.preventDefault()

decko.slotReady (slot) ->
  slot.find('card-view-placeholder').each ->
    $place = $(this)
    return if $place.data("loading")

    $place.data "loading", true
    $.get $place.data("url"), (data, _status) ->
      $place.replaceWith data

# important: this prevents jquery-mobile from taking over everything
# $( document ).on "mobileinit", ->
#   $.extend $.mobile , {
#     #autoInitializePage: false
#     #ajaxEnabled: false
#   }

snakeCase = (str)->
  str.replace /([a-z])([A-Z])/g, (match) -> match[0] + '_' +
              match[1].toLowerCase()

warn = (stuff) -> console.log stuff if console?




