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
    escapeMarkup: (markup) -> markup

    ajax:
      delay: 200
      cache: true
      url: decko.path ':search.json'
      processResults: (data) -> results: data
      data: (params) ->
        query: { keyword: params.term }
        view: "complete"
