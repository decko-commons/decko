# There are three places that can control what happens after an ajax request
#  1. the element that triggered the request (eg. a link or a button)
#  2. the closest ".slotter" element
#      (if the trigger itself isn't a slotter,
#       a common example is that a form is a slotter but the form buttons aren't)
#  3. the slot returned by the request
#
# A slot is an element marked with "card-slot" class, a slotter has a "slotter" class.
# By the default, the closest slot of the slotter is replaced with the new slot that the
# request returned. The behavior can be changed with css classes and data attributes.
#
#  To 1. The trigger element has only a few options to override the slotter.
#    classes:
#    "_close-modal-on-success"
#    "_close-overlay-on-success"
#
#  To 2. The slotter is the standard way to define what happens with request result
#    data:
#    slot-selector
#        a css selector that defines which slot will be replaced
#    slot-success-selector/slot-error-selector
#        the same as slot-selector but only used
#        for success case or error case, respectively
#    update-foreign-slot
#        a css selector to specify an additional slot that will be
#        updated after the request
#    update-foreign-slot-url
#        a url to fetch the new content for the additional slot
#        if not given the slot is updated with the same card and view that used before
#    slotter-mode
#        possible values are
#          replace (default)
#             replace the closest slot with new slot
#          modal
#             show new slot in modal
#          overlay
#             show new slot in overlay
#          update-origin
#             update closest slot of the slotter that opened the modal or overlay
#             (assumes that the request was triggered from a modal or overlay)
#             If you need the update origin together with another mode then use
#             update-foreign-slot=".card-slot._modal-origin".
#          silent-success
#             do nothing
#
#    classes:
#    _close-overlay
#    _close-modal
#
#   To 3. Similar as 1, the slot has a few overlay and modal options.
#     classes:
#     _modal
#        show slot in modal
#     _overlay
#        show slot in overlay
#
#
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
      $('body').on 'slotReady', '.card-slot', (e, slotter) ->
        e.stopPropagation()
        if slotter?
          func.call this, $(this), $(slotter)
        else
          func.call this, $(this)

jQuery.fn.extend
  slot: (status="success", mode="replace") ->
    if mode == "modal"
      @modalSlot()
    else
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

  reloadSlot: (url) ->
    $slot = $(this)
    $slot = $slot.slot() unless $slot.isSlot
    return unless $slot[0]

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

  setSlotContent: (val, mode, $slotter) ->
    v = $(val)[0] && $(val) || val

    if typeof(v) == "string"
      # Needed to support "TEXT: result" pattern in success (eg deleting nested cards)
      @slot("success", mode).replaceWith v
    else
      if v.hasClass("_overlay")
        mode = "overlay"
      else if v.hasClass("_modal")
        mode = "modal"
      @slot("success", mode).setSlotContentFromElement v, mode, $slotter
    v

  setSlotContentFromElement: (el, mode, $slotter) ->
    if mode == "overlay"
      @addOverlay(el, $slotter)
    else if el.hasClass("_modal-slot") or mode == "modal"
      el.showAsModal($slotter)
    else
      @replaceWith el

    el.triggerSlotReady($slotter)

  triggerSlotReady: (slotter) ->
    @trigger "slotReady", slotter
    @find(".card-slot").trigger "slotReady", slotter
