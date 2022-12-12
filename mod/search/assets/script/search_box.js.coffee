
$(window).ready ->
  el = $('._search-box')
  box = new decko.searchBox el
  el.data "searchBox", box
  box.init()


class decko.searchBox
  constructor: (el) ->
    @box = el
    @config =
      source: @box.data "completepath"
      select: @select

  init: -> @box.autocomplete @config, html: true

  select: (event, ui) ->
    item = ui.item
    # sb = $('._search-box').data "searchBox"
    if item.url
      window.location = item.url

#    switch item.action
#      when "goto" then sb.goto item.url
#      when "search" then sb.search item.keyword

  goto: (url) ->

  search: (keyword) ->
