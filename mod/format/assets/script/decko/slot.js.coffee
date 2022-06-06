$.extend decko,
  slot:
    # returns full path with slot parameters
    path: (path, slot)->
      params = decko.slotData slot
      decko.path(path) + ( (if path.match /\?/ then '&' else '?') + $.param(params) )

    ready: (func)->
      $('document').ready ->
        $('body').on 'decko.slot.ready', '.card-slot', (e, slotter) ->
          e.stopPropagation()
          if slotter?
            func.call this, $(this), $(slotter)
          else
            func.call this, $(this)

    destroy: (func)->
      $('document').ready ->
        $('body').on 'decko.slot.destroy', '.card-slot, ._modal-slot', (e) ->
          e.stopPropagation()
          func.call this, $(this)

  slotData: (slot) ->
    xtra = {}
    main = $('#main').children('.card-slot').data 'cardName'
    xtra['main'] = main if main?

    if slot
      xtra['is_main'] = true if slot.isMain()
      slotdata = slot.data 'slot'
      if slotdata?
        slotParams slotdata, xtra, 'slot'
        xtra['type'] = slotdata['type'] if slotdata['type']
    xtra


jQuery.fn.extend
  isSlot: -> $(this).hasClass "card-slot"

  triggerSlotReady: (slotter) ->
    @trigger "decko.slot.ready", slotter if @isSlot()
    @find(".card-slot").trigger "decko.slot.ready", slotter  
    
  slot: (status="success", mode="replace") ->
    if mode == "modal"
      @modalSlot()
    else
      @_slotSelect("slot-#{status}-selector") ||
        @_slotSelect("slot-selector") ||
        @closest(".card-slot")

  slotUrl: ->
    slot = $(this)
    decko.slot.path "#{slot.cardMark()}/#{slot.data("slot")["view"]}"

  slotFind: (selector) ->
    if selector == "modal-origin"
      @slotOrigin "modal"
    else if selector == "overlay-origin"
      @slotOrigin "overlay"
    else
      slotScour @closest(selector), @closest(".card-slot"), selector

  slotClear: () ->
    @trigger "decko.slot.destroy"
    @empty()

  # type can be "modal" or "overlay"
  slotOrigin: (type) ->
    overlaySlot = @closest("[data-#{type}-origin-slot-id]")
    origin_slot_id = overlaySlot.data("#{type}-origin-slot-id")
    origin_slot = $("[data-slot-id=#{origin_slot_id}]")
    if origin_slot[0]?
      origin_slot
    else
      decko.warn "couldn't find origin with slot id #{origin_slot_id}"

  slotReload: (url) ->
    $(this).each -> $(this)._slotReloadSingle url

  slotContent: (newContent, mode, $slotter) ->
    v = $(newContent)[0] && $(newContent) || newContent

    if typeof(v) == "string"
      # Needed to support "TEXT: result" pattern in success (eg deleting nested cards)
      @slot("success", mode).replaceWith v
    else
      if v.hasClass("_overlay")
        mode = "overlay"
      else if v.hasClass("_modal")
        mode = "modal"
      @slot("success", mode)._slotContentFromElement v, mode, $slotter
    v

  _slotContentFromElement: (el, mode, $slotter) ->
    if mode == "overlay"
      @addOverlay(el, $slotter)
    else if el.hasClass("_modal-slot") or mode == "modal"
      el.showAsModal($slotter)
    else
      slot_id = @data("slot-id")
      el.attr("data-slot-id", slot_id) if slot_id
      @trigger "decko.slot.destroy"
      @replaceWith el
      decko.contentLoaded(el, $slotter)

  _slotSelect: (selectorName) ->
    if selector = @data(selectorName)
      slot = @slotFind selector
      slot && slot[0] && slot

  _slotReloadSingle: ($slot, url) ->
    url = $slot.slotUrl() unless url?
    $slot.addClass 'slotter'
    $slot.attr 'href', url
    $slot.data "url", url
    this[0].href = url # that's where handleRemote gets the url from
    # .attr(href, url) only works for anchors
    $slot.data "remote", true
    $.rails.handleRemote $slot


slotParams = (raw, processed, prefix)->
  $.each raw, (key, value)->
    cgiKey = prefix + '[' + decko.snakeCase(key) + ']'
    if key == 'items'
      slotParams value, processed, cgiKey
    else
      processed[cgiKey] = value

slotScour = (target_slot, parent_slot, selector) ->
  # if slot-selector doesn't apply to a child, search in all parent slots and finally in the body
  while target_slot.length == 0 and parent_slot.length > 0
    target_slot = $(parent_slot).find(selector)
    parent_slot = $(parent_slot).parent().closest '.card-slot'
  if target_slot.length == 0
    $(selector)
  else
    target_slot
