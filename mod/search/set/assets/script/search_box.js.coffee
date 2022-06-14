$(window).ready ->
  searchBox = $('._search-box')
  decko.initSelect2Autocomplete(searchBox, "search_box_complete",
    searchBoxize, formatSearchBoxItem, formatSearchBoxSelectedItem,
    {
      minimumInputLength: 1
      multiple: true
      containerCssClass: 'select2-search-box-autocomplete'
      dropdownCssClass: 'select2-search-box-dropdown'
      width: "100%!important"
    })

  searchBox.on "select2:select", (e) ->
    searchBoxSelect(e)

formatSearchBoxItem = (i) ->
  if i.loading
    return i.text
  '<i class="material-icons">' + i.icon + '</i>' +
  '<span class="search-box-item-label">' + i.prefix + ':</span> ' +
  '<span class="search-box-item-value">' + i.label + '</span>'

formatSearchBoxSelectedItem = (i) ->
  unless i.icon
    return i.text
  '<i class="material-icons">' + i.icon + '</i>' +
  '<span class="search-box-item-value">' + i.label + '</span>'

searchBoxize = (results) ->
  items = []
  term = results.term
  if results["search"]
    # id is what the form sends
    items.push searchBoxItem(prefix: "search", id: term, text: term)

  $.each ['add', 'new'], (index, key) ->
    if val = results[key]
      items.push searchBoxItem(prefix: key, icon: "add", text: val[0], href: val[1])

  $.each results['goto'], (index, val) ->
    i = searchBoxItem(
      prefix: "go to", id: index, icon: "arrow_forward",
      text: val[0], href: val[1], label: val[2]
    )
    items.push i

  items

searchBoxItem = (data) ->
  data.id ||= data.prefix
  data.icon ||= data.prefix
  data.label ||= '<strong class="highlight">' + data.text + '</strong>'
  data

searchBoxSelect = (event) ->
  item = event.params.data
  if item.href
    window.location = decko.path(item.href)
  else
    $(event.target).closest('form').submit()

  $(event.target).attr('disabled', 'disabled')
