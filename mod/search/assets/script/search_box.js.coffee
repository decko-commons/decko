
$(window).ready ->
  searchBox = $('._search-box')

  decko.searchBox.init searchBox

  searchBox.on "select2:select", (e) ->
    decko.searchBox.select e

# TODO: make this more object oriented
decko.searchBox =
  init: (el) ->
    decko.select2Autocomplete.init el, @_options(),
      data: (pobj) ->
        params =
          query: { keyword: pobj.term }
          view: "search_box_complete"
        el.closest("form").serializeArray().map (p) ->
          params[p.name] = p.value unless p.name == "query[keyword]"
        params

  select: (event) ->
    # item = event.params.args.data
    href = @_eventHref event
    form = $(event.target).closest "form"
    if href
      window.location = decko.path href
    else
      form.submit()

    form.find("._search-box").attr 'disabled', 'disabled'

  _eventHref: (event) ->
    p = event.params
    d = p && p.data
    d && d.href

  _options: (_el) ->
    minimumInputLength: 1
    containerCssClass: 'select2-search-box-autocomplete'
    dropdownCssClass: 'select2-search-box-dropdown'
    allowClear: true
    width: "100%"

