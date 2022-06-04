doubleClickActiveMap = { off: false, on: true, signed_in: decko.currentUserId }

$(window).ready ->
  if doubleClickActive()
    $('body').on 'dblclick', 'div', (_event) ->
      if doubleClickApplies $(this)
        triggerDoubleClickEditingOn $(this)
      false # don't propagate up to next slot

doubleClickActive = () ->
  doubleClickActiveMap[decko.doubleClick]
  # else alert "illegal configuration: " + decko.doubleClick

doubleClickApplies = (el) ->
  return false if ['.nodblclick', '.d0-card-header', '.card-editor'].some (klass) ->
    el.closest(klass)[0]
    # double click inactive inside header, editor, or tag with "nodblclick" class
  !el.slot().find('.card-editor')[0]?

triggerDoubleClickEditingOn = (el)->
  slot = el.slot()
  edit_link = slotEditLink(slot)

  if edit_link
    edit_link.click()
  else
    edit_view = slotEditView(slot)
    url = decko.path("~#{slot.data('cardId')}?view=#{edit_view}")
    slot.reloadSlot url

slotEditLink: (slot) ->
  edit_links =
    slot.find(".edit-link").filter (i, el) ->
      $(el).slot().data('slotId') == slot.data('slotId')

  if edit_links[0] then $(edit_links[0]) else false

slotEditView: (slot) ->
  data = decko.slotData(slot)
  switch data["slot[edit]"]
    when "inline" then "edit_inline"
    when "full"   then "bridge"
    else "edit"
