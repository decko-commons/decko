$(window).ready ->
  $('body').on 'hidden.bs.modal', (_event) ->
    decko.removeModal()

  $('body').on "show.bs.modal", "._modal-slot", (event, slot) ->
    link = $(event.relatedTarget)
    addModalDialogClasses $(this), link
    $(this).modal("handleUpdate")
    decko.contentLoaded $(event.target), link

  $('._modal-slot').each ->
    openModalIfPresent $(this)
    addModalDialogClasses $(this)

  $('body').on 'click', '.submit-modal', ->
    $(this).closest('.modal-content').find('form').submit()

openModalIfPresent = (mslot) ->
  modal_content = mslot.find(".modal-content")
  if modal_content.length > 0 && modal_content.html().length > 0
    $("#main > .card-slot").registerAsOrigin("modal", mslot)
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
        $("._modal-slot").trigger "slotDestroy"
        $("body > ._modal-slot").replaceWith el
      else
        $("body").append el

      $slotter.registerAsOrigin("modal", el)
      el.modal("show", $slotter)

  addModal: (el, $slotter) ->
    if $slotter.data("slotter-mode") == "modal-replace"
      dialog = el.find(".modal-dialog")
      el.adoptModalOrigin()
      $("._modal-slot").trigger "slotDestroy"
      $("body > ._modal-slot > .modal-dialog").replaceWith(dialog)
      decko.contentLoaded(dialog, $slotter)
    else
      decko.pushModal el
      $slotter.registerAsOrigin("modal", el)
      el.modal("show", $slotter)

  adoptModalOrigin: () ->
    origin_slot_id = $("body > ._modal-slot .card-slot[data-modal-origin-slot-id]")
                        .data("modal-origin-slot-id")
    @find(".modal-body .card-slot").attr("data-modal-origin-slot-id", origin_slot_id)

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
    if $("._modal-stack")[0]
      decko.popModal()
    else
      $("._modal-slot").trigger "slotDestroy"
      $(".modal-dialog").empty()

  pushModal: (el) ->
    mslot = $("body > ._modal-slot")
    mslot.removeAttr("id")
    mslot.removeClass("_modal-slot").addClass("_modal-stack").removeClass("modal").addClass("background-modal")
    el.insertBefore mslot
    $(".modal-backdrop").removeClass("show")

  popModal: ->
    $(".modal-backdrop").addClass("show")
    $("body > ._modal-slot").trigger "slotDestroy"
    $("body > ._modal-slot").remove()
    modal = $($("._modal-stack")[0])
    modal.addClass("_modal-slot").removeClass("_modal-stack").attr("id", "modal-container").addClass("modal").removeClass("background-modal")
    $(document.body).addClass("modal-open")

