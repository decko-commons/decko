checkNameAfterTyping = null

$(window).ready ->
  $('body').on 'click', '._renamer-updater', ->
    $(this).closest('form').find('#card_update_referers').val 'true'

  $('body').on 'submit', '._rename-form', ->
    f = $(this)
    confirm = f.find '.alert'
    if confirm.is ':hidden'
      referenceConfirm f
      confirm.show 'blind'
      false

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

referenceConfirm = (form)->
  confirm = form.find '._rename-reference-confirm'
  return unless confirm.data('referer-count') > 0
  confirm.show()
  btn = form.find '._renamer-updater'
  btn.show()
  btn.focus()

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

