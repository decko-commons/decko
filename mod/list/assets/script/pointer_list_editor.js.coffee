$(window).ready ->
  # add pointer item when clicking on "add another" button
  $('body').on 'click', '._pointer-item-add', (event)->
    decko.addPointerItem this
    event.preventDefault() # Prevent link from following its href

  # add pointer item when you hit enter in an item
  $('body').on 'keydown', '.pointer-item-text', (event)->
    if event.key == 'Enter'
      decko.addPointerItem this
      event.preventDefault() # was triggering extra item in unrelated pointer

  # enable/disable add
  $('body').on 'keyup', '.pointer-item-text', (_event)->
    decko.updateAddItemButton this

  $('body').on 'click', '.pointer-item-delete', ->
    item = $(this).closest 'li'
    list =  item.closest('ul')
    if list.find('.pointer-li').length > 1
      item.remove()
    else
      item.find('input').val ''
    decko.updateAddItemButton(list)

decko.slot.ready (slot) ->
  slot.find('.pointer-list-editor').each ->
    decko.updateAddItemButton this

$.extend decko,
  addPointerItem: (el) ->
    slot = $(el).slot()
    slot.trigger "decko.slot.destroy"
    # why is this necessary?
    # this can have a lot of side effects in a multi-card form.

    newInput = decko.nextPointerInput decko.lastPointerItem(el)
    newInput.val ''

    slot.trigger "decko.slot.ready"
    decko.initializeEditors slot
    # should be (but is not) handled by decko.slot.ready
    # without this, "add another" was breaking tinymce editors in same slot

    newInput.first().focus()
    decko.updateAddItemButton el
    decko.initPointerList newInput

  nextPointerInput: (lastItem)->
    lastInputs = lastItem.find 'input'
    all_empty = true
    for input in lastInputs
        all_empty  = all_empty and $(input).val() == ''
    return lastInputs if all_empty

    newItem = lastItem.clone()
    lastItem.after newItem
    newItem.attr("data-index", parseInt(lastItem.attr("data-index") + 1))
    newItem.trigger "decko.item.added"
    newItem.find 'input'

  lastPointerItem: (el)->
    $(el).closest('.content-editor').find '.pointer-li:last'

  updateAddItemButton: (el)->
    button = $(el).closest('.content-editor').find '._pointer-item-add'
    disabled = decko.lastPointerItem(el).find('input').val() == ''
    button.prop 'disabled', disabled
