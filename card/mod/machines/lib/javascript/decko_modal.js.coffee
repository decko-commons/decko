# TODO: use same slotReady approach as below
$(window).ready ->
#  $('body').on 'hidden.bs.modal', (event) ->
#    if $(event.target).attr('id') != 'modal-main-slot'
#      modal_content = $(event.target).find('.modal-dialog > .modal-content')
#      modal_content.empty()

  $('._modal-slot').each ->
    openModalIfPresent $(this)
    addModalDialogClasses $(this)

  $('body').on "show.bs.modal", "._modal-slot", (event) ->
    link = $(event.relatedTarget)
    addModalDialogClasses $(this), link

addModalDialogClasses = ($modal_slot, $link) ->
  dialog = $modal_slot.find(".modal-dialog")
  classes_from_link =
    if $link? then $link.data("modal-class") else $modal_slot.data("modal-class")
  if classes_from_link? and dialog?
    dialog.addClass classes_from_link


decko.slotReady (slot) ->
  # this finds ._modal-slots and moves them toa the end of the body
  # this allows us to render modal slots inside slots that call them and yet
  # avoid associated problems (eg nested forms and unintentional styling)
  # note: it deletes duplicate modal slots
  slot.find('._modal-slot').each ->
    mslot = $(this)
    if $.find("body #" + mslot.attr("id")).length > 1
      mslot.remove()
    else
      $("body").append mslot

  slot.find('.modal.fade').on 'loaded.bs.modal', (_e) ->
    $(this).trigger 'slotReady'

  # found this in bootstrap_modal_wagn.js written by Henry in 2015
  # don't know if we still need it  -pk
#  slot.find('[data-toggle="modal"]').off('click').on 'click', (e) ->
#    e.preventDefault()
#    e.stopPropagation()
#    $this = $(this)
#    href = $this.attr('href')
#    modal_selector = $this.data('target')
#    $(modal_selector).modal 'show', $this
#    $.ajax
#      url: href
#      type: 'GET'
#      success: (html) ->
#        $(modal_selector + ' .modal-content').html html
#        $(modal_selector).trigger 'loaded.bs.modal'
#      error: (jqXHR, textStatus) ->
#        $(modal_selector + ' .modal-content').html jqXHR.responseText
#        $(modal_selector).trigger 'loaded.bs.modal'

modalSlot = ->
  slot = $("#modal-container")
  if slot.length > 0 then slot else createModalSlot()

createModalSlot = ->
  #slot = $('<div/>', class: "card-slot")
  slot = $('<div/>', id: "modal-container", class: "modal fade _modal-slot")
  $("body").append(slot)
  #$('<div/>', id: "modal-container", class: "modal fade _modal-slot") #.append(slot)
  #)
  slot

openModalIfPresent = (mslot) ->
  modal_content = mslot.find(".modal-content")
  if modal_content.length > 0 && modal_content.html().length > 0
    mslot.modal("show")

