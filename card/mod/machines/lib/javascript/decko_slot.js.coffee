$.extend decko,
  # returns full path with slot parameters
  slotPath: (path, slot)->
    xtra = {}
    main = $('#main').children('.card-slot').data 'cardName'
    xtra['main'] = main if main?
    if slot
      xtra['is_main'] = true if slot.isMain()
      slotdata = slot.data 'slot'
      decko.slotParams slotdata, xtra, 'slot' if slotdata?

    decko.path(path) + ( (if path.match /\?/ then '&' else '?') + $.param(xtra) )

  slotParams: (raw, processed, prefix)->
    $.each raw, (key, value)->
      cgiKey = prefix + '[' + snakeCase(key) + ']'
      if key == 'items'
        decko.slotParams value, processed, cgiKey
      else
        processed[cgiKey] = value

  slotReady: (func)->
    $('document').ready ->
      $('body').on 'slotReady', '.card-slot', (e) ->
        e.stopPropagation()
        func.call this, $(this)

jQuery.fn.extend {
  slot: (status="success") ->
    @selectSlot("slot-#{status}-selector") ||
      @selectSlot("slot-selector") ||
      @closest(".card-slot")

  selectSlot: (selectorName) ->
    if selector = @data(selectorName)
      slot = @findSlot selector
      slot[0] && slot

  isSlot: ->
    $(this).hasClass "card-slot"

  isMain: -> @slot().parent('#main')[0]

  findSlot: (selector) ->
    target_slot = @closest(selector)
    parent_slot = @closest '.card-slot'

    # if slot-selector doesn't apply to a child, search in all parent slots and finally in the body
    while target_slot.length == 0 and parent_slot.length > 0
      target_slot = $(parent_slot).find(selector)
      parent_slot = $(parent_slot).parent().closest '.card-slot'
    if target_slot.length == 0
      $(selector)
    else
      target_slot

  updateSlot: (url) ->
    $slot = $(this)
    $slot = $slot.slot() unless $slot.isSlot
    unless url?
      path = '~' + $slot.data('cardId') + "?view=" + $slot.data("slot")["view"]
      url = decko.slotPath path, $slot
    $slot.addClass 'slotter'
    $slot.attr 'href', url
    $slot.data "url", url
    this[0].href = url # that's where handleRemote gets the url from
                       # .attr(href, url) only works for anchors
    $slot.data "remote", true
    $.rails.handleRemote($slot)

  setSlotContent: (val, _overlay=false) ->
    s = @slot()
    el = $(val)[0] && $(val) || val
    s.updateSlotWithElement el
    el.triggerSlotReady()
    el

  updateSlotWithElement: (el) ->
    s = $(this)
    if el.hasClass("_overlay")
      s.wrapAll('<div class="overlay-container">')
      s.before el
    else
      s.replaceWith el

  triggerSlotReady: () ->
    @trigger "slotReady"
    @find(".card-slot").trigger "slotReady"

  slotSuccess: (data, overlay) ->
    if data.redirect
      window.location=data.redirect
    else
      notice = @attr('notify-success')
      newslot = @setSlotContent data, overlay

      if newslot.jquery # sometimes response is plaintext
        decko.initializeEditors newslot
        if notice?
          newslot.notify notice, "success"

  slotError: (status, result) ->
    if status == 403 #permission denied
      @setSlotContent result
    else
      @notify result, "error"
      if status == 409 #edit conflict
        @slot().find('.current_revision_id').val(
          @slot().find('.new-current-revision-id').text()
        )
      else if status == 449
        @slot().find('g-recaptcha').reloadCaptcha()
}
