decko.slot.ready (slot)->
  slot.find('._setting-filter').each () ->
    decko.filterRulesByCategory $(this).closest(".card-slot"), $(this).find('input._setting-category:checked').attr("id")

$.extend decko,
  filterRulesByCategory: (container, category) ->
    $(container).find('._setting-list').each (_i) ->
      $list = $(this)
      items = $list.find('._rule-item')
      hiddenCount = 0
      items.each () ->
        $item = $(this)
        wrapper = if $item.parent().is("li") then $item.parent() else $item
        if $item.hasClass("_category-#{category}")
          wrapper.show()
        else
          wrapper.hide()
          hiddenCount += 1

      if (hiddenCount == items.length)
        $list.hide()
      else
        $list.show()

$(window).ready ->
  # permissions mod
  $('body').on 'click', '.perm-vals input', ->
    $(this).slot().find('#inherit').attr('checked',false)

  $('body').on 'click', '.perm-editor #inherit', ->
    slot = $(this).slot()
    slot.find('.perm-group input:checked').attr('checked', false)
    slot.find('.perm-indiv input').val('')

  # rstar mod
  $('body').on 'click', '._rule-submit-button', ->
    f = $(this).closest('form')
    checked = f.find('.set-editor input:checked')
    if checked.val()
      if checked.attr('warning')
        confirm checked.attr('warning')
      else
        true
    else
      f.find('.set-editor').addClass('warning')
      $(this).notify 'To what Set does this Rule apply?'
      false

  $('body').on 'click', 'input._setting-category', ->
    category = $(this).attr("id")
    decko.filterRulesByCategory($(this).closest('.card-slot'), category)
