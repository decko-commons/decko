$(window).ready ->
  navbox = $('._navbox')
  decko.initSelect2Autocomplete(navbox, "navbox_complete",
    navboxize, formatNavboxItem, formatNavboxSelectedItem,
    {
      minimumInputLength: 1
      multiple: true
      containerCssClass: 'select2-navbox-autocomplete'
      dropdownCssClass: 'select2-navbox-dropdown'
      width: "100%!important"
    })

  navbox.on "select2:select", (e) ->
    navboxSelect(e)

formatNavboxItem = (i) ->
  if i.loading
    return i.text
  '<i class="material-icons">' + i.icon + '</i>' +
  '<span class="navbox-item-label">' + i.prefix + ':</span> ' +
  '<span class="navbox-item-value">' + i.label + '</span>'

formatNavboxSelectedItem = (i) ->
  unless i.icon
    return i.text
  '<i class="material-icons">' + i.icon + '</i>' +
  '<span class="navbox-item-value">' + i.label + '</span>'

navboxize = (results) ->
  items = []
  term = results.term
  if results["search"]
    # id is what the form sends
    items.push navboxItem(prefix: "search", id: term, text: term)

  $.each ['add', 'new'], (index, key) ->
    if val = results[key]
      items.push navboxItem(prefix: key, icon: "add", text: val[0], href: val[1])

  $.each results['goto'], (index, val) ->
    i = navboxItem(
      prefix: "go to", id: index, icon: "arrow_forward",
      text: val[0], href: val[1], label: val[2]
    )
    items.push i

  items

navboxItem = (data) ->
  data.id ||= data.prefix
  data.icon ||= data.prefix
  data.label ||= '<strong class="highlight">' + data.text + '</strong>'
  data

navboxSelect = (event) ->
  item = event.params.data
  if item.href
    window.location = decko.path(item.href)
  else
    $(event.target).closest('form').submit()

  $(event.target).attr('disabled', 'disabled')
