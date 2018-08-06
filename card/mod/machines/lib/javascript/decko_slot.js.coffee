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
    v = $(val)[0] && $(val) || val


    if typeof(v) == "string"
      # Needed to support "TEXT: result" pattern in success (eg deleting nested cards)
      @slot().replaceWith v
    else
      if v.hasClass("_overlay")
        mode == "overlay"
      else if v.hasClass("_modal")
        mode == "modal"

      s = if mode == "modal" then modalSlot() else @slot()
      s.setSlotContentFromElement v
    v

  setSlotContentFromElement: (el, mode) ->
    s = $(this)
    if mode == "overlay"
      s.addOverlay(el)    
    else
      s.replaceWith el
      if mode == "modal"
        el.modalify()
        el.closest("#modal-container").modal("show")
    el.triggerSlotReady()

  triggerSlotReady: () ->
    @trigger "slotReady"
    @find(".card-slot").trigger "slotReady"
  
  addOverlay: (overlay) ->
    unless @parent().hasClass("overlay-container")
      @wrapAll('<div class="overlay-container">')
      @addClass("_bottomlay-slot")
    @before overlay

  modalify: ->
    unless @hasClass("modal-dialog")
      @addClass("modal-dialog").wrapInner('<div class="modal-content">')
  
  # mode can be "standard", "overlay" or "modal"
  slotSuccess: (data, mode) ->
    if data.redirect
      window.location=data.redirect
    else
      notice = @attr('notify-success')
      mode ||= "standard"
      newslot = @setSlotContent data, mode

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
