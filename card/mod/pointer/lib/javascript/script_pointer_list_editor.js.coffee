$(window).ready ->
  # add pointer item when clicking on "add another" button
  $('body').on 'click', '.pointer-item-add', (event)->
    decko.addPointerItem this
    event.preventDefault() # Prevent link from following its href

  # add pointer item when you hit enter in an item
  $('body').on 'keydown', '.pointer-item-text', (event)->
    if event.key == 'Enter'
      decko.addPointerItem this
      event.preventDefault() # was triggering extra item in unrelated pointer

  $('body').on 'keyup', '.pointer-item-text', (_event)->
    decko.updateAddItemButton this

  $('body').on 'click', '.pointer-item-delete', ->
    item = $(this).closest 'li'
    if item.closest('ul').find('.pointer-li').length > 1
      item.remove()
    else
      item.find('input').val ''

decko.slotReady (slot) ->
  slot.find('.pointer-list-editor').each ->
    decko.updateAddItemButton this

$.extend decko,
  addPointerItem: (el) ->
    newInput = decko.nextPointerInput decko.lastPointerItem(el)
    newInput.val ''
    newInput.focus()
    decko.updateAddItemButton el
    decko.initPointerList newInput

  nextPointerInput: (lastItem)->
    lastInput = lastItem.find 'input'
    return lastInput if lastInput.val() == ''
    newItem = lastItem.clone()
    lastItem.after newItem
    newItem.find 'input'

  lastPointerItem: (el)->
    $(el).closest('.content-editor').find '.pointer-li:last'

  updateAddItemButton: (el)->
    button = $(el).closest('.content-editor').find '.pointer-item-add'
    disabled = decko.lastPointerItem(el).find('input').val() == ''
    button.prop 'disabled', disabled
