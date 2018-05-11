$(window).ready ->
  $.fn.select2.amd.require([
    'select2/selection/single'
    'select2/selection/multiple',
    'select2/selection/search',
    'select2/dropdown',
    'select2/dropdown/attachBody',
    'select2/dropdown/closeOnSelect',
    'select2/compat/containerCss',
    'select2/utils'
  ], (SingleSelection, MultipleSelection, Search, Dropdown, AttachBody, CloseOnSelect, ContainerCss, Utils) ->

    SelectionAdapter = Utils.Decorate(MultipleSelection, Search, ContainerCss)

    DropdownAdapter = Utils.Decorate(
      Utils.Decorate(Dropdown, CloseOnSelect),
      AttachBody
    )

    navbox = $('._navbox')
    navbox.select2
      placeholder: navbox.attr("placeholder")
      escapeMarkup: (markup) ->
        markup
      minimumInputLength: 1
      maximumSelectionSize: 1
      ajax:
        url: decko.path ':search.json'
        data: (params) ->
          query: { keyword: params.term }
          view: "complete"
        processResults: (data) ->
          results: navboxize(data)
        cache: true
      allowClear: false
      templateResult: formatNavboxItem
      templatSelection: formatNavboxSelectedItem
      selectionAdapter: Utils.Decorate(MultipleSelection, Search, ContainerCss)
      dropdownAdapter: DropdownAdapter
      containerCssClass: ':all:'
  )
  $("body").on "select2:select", "._navbox", (e) ->
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

  $(this).attr('disabled', 'disabled')
