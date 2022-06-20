
$(window).ready ->
  searchBox = $('._search-box')
  decko.searchBox.init searchBox

  searchBox.on "select2:select", (e) ->
    # e.preventDefault()
    decko.searchBox.select e


# TODO: make this more object oriented
decko.searchBox =
  init: (el) ->
    process = @_process
    decko.select2Autocomplete.init el, @_options(),
      processResults: (data) ->
        results: process(data)
      data: (pobj) ->
        params =
          query: { keyword: pobj.term }
          view: "search_box_complete"
        el.closest("form").serializeArray().map (p) -> params[p.name] = p.value
        params

  select: (event) ->
    # item = event.params.args.data
    item = event.params.data
    if item.href
      window.location = decko.path(item.href)
    else
      $(event.target).closest('form').submit()

    $(event.target).attr('disabled', 'disabled')


  _options: (_el) ->
    minimumInputLength: 1
    containerCssClass: 'select2-search-box-autocomplete'
    dropdownCssClass: 'select2-search-box-dropdown'
    templateResult: @_templateResult
    templateSelection: @_templateSelection
    width: "100%"

  _templateResult: (i) ->
    return i.text if i.loading
    '<i class="material-icons">' + i.icon + '</i>' +
    '<span class="search-box-item-label">' + i.prefix + ':</span> ' +
    '<span class="search-box-item-value">' + i.label + '</span>'

  _templateSelection: (i) ->
    return i.text unless i.icon
    '<i class="material-icons">' + i.icon + '</i>' +
    '<span class="search-box-item-value">' + i.label + '</span>'

  _process: (results) ->
    box = decko.searchBox
    items = []

    items.push box._searchItem(results.term) if results["search"]
    $.each ['add', 'new'], (_index, key) ->
      val = results[key]
      items.push box._addItem(key, val) if val
    $.each results['goto'], (index, val) ->
      items.push box._gotoItem(index, val)
    items

  _searchItem: (term) ->
    @_normalizeItem
      prefix: "search"
      id: term
      text: term

  _addItem: (key, val) ->
    @_normalizeItem
      prefix: key
      icon: "add"
      text: val[0]
      href: val[1]

  _gotoItem: (index, val) ->
   @_normalizeItem
     prefix: "go to"
     id: index
     icon: "arrow_forward"
     text: val[0]
     href: val[1]
     label: val[2]

  _normalizeItem: (data) ->
    data.id ||= data.prefix
    data.icon ||= data.prefix
    data.label ||= '<strong class="highlight">' + data.text + '</strong>'
    data

