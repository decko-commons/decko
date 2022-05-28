checkNameAfterTyping = null

$(window).ready ->
  $('body').on 'keyup', '.name-editor input', (event) ->
    clearTimeout(checkNameAfterTyping) if checkNameAfterTyping
    input = $(this)
    if event.which == 13
      checkName(input)
      checkNameAfterTyping = null
    else
      checkNameAfterTyping = setTimeout ->
          checkName(input)
          checkNameAfterTyping = null
        , 400

decko.pingName = (name, success)->
  $.getJSON decko.path(''), format: 'json', view: 'status', 'card[name]': name, success


checkName = (box) ->
  name = box.val()
  decko.pingName name, (data)->
    return null if box.val() != name # avert race conditions
    status = data['status']
    if status
      ed = box.parent()
      leg = box.closest('fieldset').find('legend')
      msg = leg.find '.name-messages'
      unless msg[0]
        msg = $('<span class="name-messages"></span>')
        leg.append msg?
      ed.removeClass 'real-name virtual-name known-name'

      # use id to avoid warning when renaming to name variant
      slot_id = box.slot().data 'cardId'
      if status != 'unknown' and !(slot_id && parseInt(slot_id) == data['id'])
        ed.addClass status + '-name known-name'
        qualifier = if status == 'virtual' then 'in virtual' else 'already in'
        href = decko.path(data['url_key'])
        msg.html "\"<a href='#{href}'>#{name}</a>\" #{qualifier} use"
      else
        msg.html ''

