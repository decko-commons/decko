window.decko =
  rootUrl: "" # overwritten in inline script in head

  # returns absolute path (starting with a slash)
  # if rawPath is complete url, this returns the complete url
  # if rawPath is relative (no slash), this adds relative root
  path: (rawPath) ->
    if rawPath.match /^\/|:\/\//
      rawPath
    else
      decko.rootUrl + rawPath

  editors:
    init: {}
    content: {}
    add: (selector, initf, contentf)->
      decko.editors.init[selector] = initf
      decko.editors.content[selector] = contentf

  warn: (stuff) -> console.log stuff if console?

  snakeCase: (str)->
    str.replace /([a-z])([A-Z])/g, (match) -> match[0] + '_' +
      match[1].toLowerCase()


#~~~~~ ( EVENTS )

$(window).ready ->
  $.ajaxSetup cache: false

  $('body').on 'click', '.submitter', ->
    $(this).closest('form').submit()

  $('body').on 'click', 'button.redirecter', ->
    window.location = $(this).attr('href')

  $('body').on 'click', '.render-error-link', (event) ->
    msg = $(this).closest('.render-error').find '.render-error-message'
    msg.show()
#    msg.dialog()
    event.preventDefault()

  $(document).on 'click', '._stop_propagation', (event)->
    event.stopPropagation()

  $("body").on 'click', '._prevent_default', (event)->
    event.preventDefault()

  $('body').on 'mouseenter', 'a[data-hover-text]', ->
    text = $(this).text()
    $(this).data("original-text", text)
    $(this).text($(this).data("hover-text"))

  $('body').on 'mouseleave', 'a[data-hover-text]', ->
    $(this).text($(this).data("original-text"))

  $('body').on 'mouseenter', '[hover_content]', ->
    $(this).attr 'hover_restore', $(this).html()
    $(this).html $(this).attr( 'hover_content' )

  $('body').on 'mouseleave', '[hover_content]', ->
    $(this).html $(this).attr( 'hover_restore' )

