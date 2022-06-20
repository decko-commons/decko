decko.slot.ready (slot) ->
  slot.find('._autocomplete').each (_i) ->
    decko.initAutoCardPlete($(this))

  slot.find('._select2autocomplete').each (_i) ->
    decko.select2Autocomplete.init $(this)

decko.initAutoCardPlete = (input) ->
  optionsCard = input.data 'options-card'
  return unless !!optionsCard
  path = optionsCard + '.json?view=name_match'
  input.autocomplete { source: decko.slot.path(path) }

decko.select2Autocomplete =
  init: (el, options, ajaxOptions) ->
    opts = $.extend {}, @_defaults(el), options
    $.extend opts.ajax, ajaxOptions if ajaxOptions
    el.select2 opts


  _defaults: (el)->
    multiple: false
    width: "100%!important"
    minimumInputLength: 0
    maximumSelectionSize: 1

    placeholder: el.attr("placeholder")
    templateResult: @_templateResult
    templateSelection: @_templateSelection
    escapeMarkup: (markup) -> markup

    ajax:
      delay: 200
      cache: true
      url: decko.path ':search.json'
      processResults: (data) ->
        results: @_prepareItems(data)
      data: (params) ->
        query: { keyword: params.term }
        view: "complete"

  _templateResult: (i) ->
    return i.text if i.loading
    @_templateSelection i

  _templateSelection: (i) ->
    '<span class="search-box-item-value ml-1">' + i.text + '</span>'

  _prepareItems: (response) ->
    items = []
    $.each response['result'], (index, val) ->
      items.push id: val[0], text: val[0]
    items


#$.extend decko,
#  initSelect2Autocomplete: (el, search_view,
#    prepareItems=decko.autocompletePrepareItems,
#    templateResult=decko.autocompleteTemplateResult,
#    templateSelection=decko.autocompleteTemplateSelection,
#    options={}) ->
#
#    defaultOptions =
#      placeholder: el.attr("placeholder")
#      escapeMarkup: (markup) ->
#        markup
#      minimumInputLength: 0
#      maximumSelectionSize: 1
#      ajax:
#        delay: 200
#        url: decko.path ':search.json'
#        data: (params) ->
#          query: {keyword: params.term}
#          view: search_view
#        processResults: (data) ->
#          results: prepareItems(data)
#        cache: true
#      templateResult: templateResult
#      templateSelection: templateSelection
#      multiple: false
#      width: "100%!important"
#    $.extend defaultOptions, options
#    el.select2 defaultOptions
