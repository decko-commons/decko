doubleClickActiveMap = { off: false, on: true, signed_in: decko.currentUserId }

doubleClickActive = () ->
  doubleClickActiveMap[decko.doubleClick]
  # else alert "illegal configuration: " + decko.doubleClick

doubleClickApplies = (el) ->
  return false if ['.nodblclick', '.d0-card-header', '.card-editor', '.bridge-sidebar'].some (klass) ->
    el.closest(klass)[0]
    # double click inactive inside header, editor, or tag with "nodblclick" class
  slot = el.slot()
  return false if slot.find('.card-editor')[0]
  # false if there is a card-editor open inside slot
  slot.data 'cardId'

triggerDoubleClickEditingOn = (el)->
  slot = el.slot()
  slot.addClass 'slotter'

  edit_mode= decko.slotEditMode(slot)
  slot[0].href = decko.path('~' + slot.data('cardId') + "?view=edit_#{edit_mode}")
  $.rails.handleRemote slot

$(window).ready ->
  if doubleClickActive()
    $('body').on 'dblclick', 'div', (_event) ->
      if doubleClickApplies $(this)
        triggerDoubleClickEditingOn $(this)
      false # don't propagate up to next slot
