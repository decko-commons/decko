$.extend decko,
  prepUrl: (url, slot)->
    xtra = {}
    main = $('#main').children('.card-slot').data 'cardName'
    xtra['main'] = main if main?
    if slot
      xtra['is_main'] = true if slot.isMain()
      slotdata = slot.data 'slot'
      decko.slotParams slotdata, xtra, 'slot' if slotdata?

    url + ( (if url.match /\?/ then '&' else '?') + $.param(xtra) )

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
    if @data("slot-#{status}-selector")
      @findSlot(@data("slot-#{status}-selector"))
    else if @data("slot-selector")
      @findSlot(@data("slot-selector"))
    else
      @closest '.card-slot'

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
      url = decko.rootPath + '/~' + $slot.data('cardId') + "?view=" +
        $slot.data("slot")["view"]
      url = decko.prepUrl url, $slot
    $slot.addClass 'slotter'
    $slot.attr 'href', url
    $.rails.handleRemote($slot)

  setSlotContent: (val, overlay=false) ->
    s = @slot()
    v = $(val)
    unless v[0]
#   if slotdata = s.attr 'data-slot'
#     v.attr 'data-slot', slotdata if slotdata?
# else #simple text (not html)
      v = val
    if overlay
      s.prepend v
      v.addClass "slot-overlay"
    else
      s.replaceWith v
    v.trigger 'slotReady'
    v


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
