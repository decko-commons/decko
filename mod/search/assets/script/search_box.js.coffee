
$(window).ready ->
  el = $('._search-box')
  box = new decko.searchBox el
  el.data "searchBox", box
  box.init()

class decko.searchBox
  constructor: (el) ->
    @box = el
    @sourcepath = @box.data "completepath"
    @originalpath = @sourcepath
    @config =
      source: @sourcepath
      select: @select

  init: ->
    debugger
    @box.autocomplete @config, html: true

  select: (_event, ui) ->
    url = ui.item.url
    window.location = url if url

  form: -> @box.closest "form"
  keyword: -> form.find("#query_keyword").val()
