decko.slot.ready (slot) ->
  slot.find('._autocomplete').each (_i) ->
    decko.initAutoCardPlete($(this))

  slot.find('._select2autocomplete').each (_i) ->
    decko.initSelect2Autocomplete($(this), "complete")

$.extend decko,
  initSelect2Autocomplete: (el, search_view,
    prepareItems=decko.autocompletePrepareItems,
    templateResult=decko.autocompleteTemplateResult,
    templateSelection=decko.autocompleteTemplateSelection,
    options={}) ->

    defaultOptions = {
      placeholder: el.attr("placeholder")
      escapeMarkup: (markup) ->
        markup
      minimumInputLength: 0
      maximumSelectionSize: 1
      ajax:
        delay: 200
        url: decko.path ':search.json'
        data: (params) ->
          query: {keyword: params.term}
          view: search_view
        processResults: (data) ->
          results: prepareItems(data)
        cache: true
      templateResult: templateResult
      templateSelection: templateSelection
      multiple: false
      width: "100%!important"
    }
    $.extend defaultOptions, options
    el.select2 defaultOptions

  autocompleteTemplateResult: (i) ->
    if i.loading
      return i.text
    '<span class="search-box-item-value ml-1">' + i.text + '</span>'

  autocompleteTemplateSelection: (i) ->
    '<span class="search-box-item-value ml-1">' + i.text + '</span>'

  autocompletePrepareItems: (response) ->
    items = []
    $.each response['result'], (index, val) ->
      items.push id: val[0], text: val[0]
    items

  initAutoCardPlete: (input) ->
    optionsCard = input.data 'options-card'
    return unless !!optionsCard
    path = optionsCard + '.json?view=name_match'
    input.autocomplete { source: decko.slot.path(path) }