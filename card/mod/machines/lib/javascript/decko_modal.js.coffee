# TODO: use same slotReady approach as below
$(window).ready ->
#  $('body').on 'hidden.bs.modal', (event) ->
#    if $(event.target).attr('id') != 'modal-main-slot'
#      modal_content = $(event.target).find('.modal-dialog > .modal-content')
#      modal_content.empty()

  $('._modal-slot').each ->
    openModalIfPresent $(this)
    addModalDialogClasses $(this)

addModalDialogClasses = ($modal_slot, $link) ->
  dialog = $modal_slot.find(".modal-dialog")
  classes_from_link =
    if $link? then $link.data("modal-class") else $modal_slot.data("modal-class")
  if classes_from_link? and dialog?
    dialog.addClass classes_from_link

decko.slotReady (slot) ->
  $('body').on "show.bs.modal", "._modal-slot", (event) ->
    link = $(event.relatedTarget)
    addModalDialogClasses $(this), link
    $(this).modal("handleUpdate")

  $('body').on 'hidden.bs.modal', (_event) ->
    decko.removeModal()

  # this finds ._modal-slots and moves them toa the end of the body
  # this allows us to render modal slots inside slots that call them and yet
  # avoid associated problems (eg nested forms and unintentional styling)
  # note: it deletes duplicate modal slots
  # not sure if we still need this -pk
  slot.find('._modal-slot').each ->
    mslot = $(this)
    if $.find("body #" + mslot.attr("id")).length > 1
      mslot.remove()
    else
      $("body").append mslot

  slot.find('.modal.fade').on 'loaded.bs.modal', (_e) ->
    $(this).trigger 'slotReady'

openModalIfPresent = (mslot) ->
  modal_content = mslot.find(".modal-content")
  if modal_content.length > 0 && modal_content.html().length > 0
    $("#main > .card-slot").addClass("_modal-origin")
    mslot.modal("show")

jQuery.fn.extend {
  showAsModal: ($slotter) ->
    el = @modalify($slotter)
    if $("body > ._modal-slot").is(":visible")
      decko.pushModal el
    else
      if $("body > ._modal-slot")[0]
        $("body > ._modal-slot").replaceWith el
      else
        $("body").append el

      $("._modal-origin").removeClass("_modal-origin")

    $slotter.markOrigin("modal")
    el.modal("show", $slotter)

  modalSlot: ->
    slot = $("#modal-container")
    if slot.length > 0 then slot else decko.createModalSlot()

  modalify: ($slotter) ->
    if $slotter.data("modal-body")?
      @find(".modal-body").append($slotter.data("modal-body"))

    if @hasClass("_modal-slot")
      this
    else
      modalSlot = $('<div/>', id: "modal-container", class: "modal fade _modal-slot")
      modalSlot.append(
        $('<div/>' , class: "modal-dialog").append(
          $('<div/>', class: "modal-content").append(this)
        )
      )
      modalSlot
}

$.extend decko,
  createModalSlot: ->
    slot = $('<div/>', id: "modal-container", class: "modal fade _modal-slot")
    $("body").append(slot)
    slot

  removeModal: ->
    if $("._modal-fallback")[0]
      decko.popModal()
    else
      $(".modal-dialog").remove()

  pushModal: (el) ->
    mslot = $("body > ._modal-slot").detach()
    mslot.removeClass("_modal-slot").addClass("_modal-fallback")
    mslot.insertAfter(".modal-backdrop")
    el.insertBefore(".modal-backdrop")

  popModal: ->
    modal = $($("._modal-fallback")[0]).detach()
    modal.addClass("_modal-slot").removeClass("_modal-fallback")
    $("body > ._modal-slot").replaceWith(modal)

