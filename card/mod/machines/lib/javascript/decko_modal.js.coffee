$(window).ready ->
  $('body').on 'hidden.bs.modal', (_event) ->
    decko.removeModal()

  $('body').on "show.bs.modal", "._modal-slot", (event) ->
    link = $(event.relatedTarget)
    addModalDialogClasses $(this), link
    $(this).modal("handleUpdate")

  $('body').on 'loaded.bs.modal', null, (event) ->
    unless event.slotSuccessful
      decko.initModal $(event.target)
      event.slotSuccessful = true

  $('._modal-slot').each ->
    openModalIfPresent $(this)
    addModalDialogClasses $(this)

decko.slotReady (slot) ->
  slot.find('.modal.fade').on 'loaded.bs.modal', (_e) ->
    $(this).trigger 'slotReady'

openModalIfPresent = (mslot) ->
  modal_content = mslot.find(".modal-content")
  if modal_content.length > 0 && modal_content.html().length > 0
    $("#main > .card-slot").addClass("_modal-origin")
    mslot.modal("show")

addModalDialogClasses = ($modal_slot, $link) ->
  dialog = $modal_slot.find(".modal-dialog")
  classes_from_link =
    if $link? then $link.data("modal-class") else $modal_slot.data("modal-class")
  if classes_from_link? and dialog?
    dialog.addClass classes_from_link

jQuery.fn.extend {
  showAsModal: ($slotter) ->
    el = @modalify($slotter) if $slotter?
    if $("body > ._modal-slot").is(":visible")
      @addModal el, $slotter
    else
      if $("body > ._modal-slot")[0]
        $("body > ._modal-slot").replaceWith el
      else
        $("body").append el

      $("._modal-origin").removeClass("_modal-origin")
      $slotter.registerAsOrigin("modal", el.find(".modal-body > .card-slot"))
      el.modal("show", $slotter)

  addModal: (el, $slotter) ->
    if $slotter.data("slotter-mode") == "modal-replace"
      dialog = el.find(".modal-dialog")
      $("body > ._modal-slot > .modal-dialog").replaceWith(dialog)
      decko.initModal dialog
    else
      decko.pushModal el
      $slotter.registerAsOrigin("modal", el)
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

  initModal: ($dialog) ->
    decko.initializeEditors $dialog
    $dialog.find(".card-slot").trigger("slotReady")

  removeModal: ->
    if $("._modal-stack")[0]
      decko.popModal()
    else
      $(".modal-dialog").empty()

  pushModal: (el) ->
    mslot = $("body > ._modal-slot")
    mslot.removeAttr("id")
    mslot.removeClass("_modal-slot").addClass("_modal-stack").removeClass("modal").addClass("background-modal")
    el.insertBefore mslot
    $(".modal-backdrop").removeClass("show")


  popModal: ->
    $(".modal-backdrop").addClass("show")
    $("body > ._modal-slot").remove()
    modal = $($("._modal-stack")[0])
    modal.addClass("_modal-slot").removeClass("_modal-stack").attr("id", "modal-container").addClass("modal").removeClass("background-modal")
