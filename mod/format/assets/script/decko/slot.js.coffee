decko.slot =
  # returns full path with slot parameters
  path: (path, slot, slotterMode)->
    params = slotPathParams slot
    params["slotter_mode"] = slotterMode if slotterMode?
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

jQuery.fn.extend
  isSlot: -> $(this).hasClass "card-slot"

  triggerSlotReady: (slotter) ->
    @trigger "decko.slot.ready", slotter if @isSlot()
    @find(".card-slot").trigger "decko.slot.ready", slotter

  slot: (status="success", mode="replace") ->
    return @modalSlot() if mode == "modal"

    @_slotSelect("slot-#{status}-selector") ||
      @_slotSelect("slot-selector") ||
      @closest(".card-slot")

  slotUrl: ->
    slot = $(this)
    decko.slot.path "#{slot.cardMark()}/#{slot.data("slot")["view"]}"

  slotFind: (selector) ->
    switch selector
      when "modal-origin"   then @slotOrigin "modal"
      when "overlay-origin" then @slotOrigin "overlay"
      else slotScour @closest(selector), @closest(".card-slot"), selector

  slotClear: () ->
    @trigger "decko.slot.destroy"
    @empty()

  # type can be "modal" or "overlay"
  slotOrigin: (type) ->
    overlaySlot = @closest("[data-#{type}-origin-slot-id]")
    origin_slot_id = overlaySlot.data("#{type}-origin-slot-id")
    origin_slot = $("[data-slot-id=#{origin_slot_id}]")
    if origin_slot.length > 0
      origin_slot
    else
      decko.warn "couldn't find origin with slot id #{origin_slot_id}"

  slotReload: (url) ->
    @each -> $(this)._slotReloadSingle url

  slotReloading: ()->
    # TODO: add default spinner behavior

#  slotLoadingComplete: ()->
#    # TODO: add default spinner behavior

  slotUpdate: (newContent, mode) ->
    mode ||= "replace"
    @slotContent newContent, mode, $(this)

  slotContent: (newContent, mode, $slotter) ->
    v = $(newContent).length > 0 && $(newContent) || newContent

    if typeof(v) == "string"
      # Needed to support "TEXT: result" pattern in success (eg deleting nested cards)
      @slot("success", mode)._slotFillOrReplace v, $slotter
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
      @_slotFillOrReplace el, $slotter
      decko.contentLoaded(el, $slotter)

  _slotFillOrReplace: (content, $slotter) ->
    if @hasClass("_fixed-slot")
      @html content
    else
      @replaceWith content
    decko.contentLoaded(this, $slotter)

  _slotSelect: (selectorName) ->
    if selector = @data(selectorName)
      slot = @slotFind selector
      slot && slot[0] && slot

  _slotReloadSingle: (url) ->
    $slot = $(this)
    url = $slot.slotUrl() unless url?
    $slot.addClass 'slotter'
    $slot.data "url", url
    $slot.data "remote", true
    $slot.attr 'href', url
    this[0].href = url
    # that's where handleRemote gets the url from
    # .attr(href, url) only works for anchors
    $.rails.handleRemote $slot
    $slot.slotReloading()

# ~~~~~~~~~~~~~~~~~~~~~~~~
# "private" helper methods

slotPathParams = (slot) ->
  params = {}
  main = $('#main').children('.card-slot').data 'cardName'
  params['main'] = main if main?

  if slot
    params['is_main'] = true if slot.isMain()
    slotdata = slot.data 'slot'
    if slotdata?
      slotParams slotdata, params, 'slot'
      params['type'] = slotdata['type'] if slotdata['type']
  params

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
