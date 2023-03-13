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

  $('body').on 'click', '._confirm', ->
    confirm $(this).data('confirm-msg') || 'Are you sure?'




