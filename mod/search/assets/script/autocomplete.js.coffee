decko.slotReady (slot) ->
  slot.find('_autocomplete').each (_i) ->
    decko.initAutoCardPlete($(this))

$.extend decko,
  initAutoCardPlete: (input) ->
    optionsCard = input.data 'options-card'
    return unless !!optionsCard
    path = optionsCard + '.json?view=name_match'
    input.autocomplete { source: decko.slotPath(path) }