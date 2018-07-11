# TODO: use same slotReady approach as below
$(window).ready ->
  $('body').on 'hidden.bs.modal', (event) ->
    if $(event.target).attr('id') != 'modal-main-slot'
      modal_content = $(event.target).find('.modal-dialog > .modal-content')
      modal_content.empty()
      refresh_menu($(event.target).slot())

  $('._modal-slot').each ->
    openModalIfPresent $(this)


  $("._modal-slot").on "show.bs.modal", (event) ->
    link = $(event.target)
    dialog = $(this).find(".modal-dialog")
    dialog.attr("class", "modal-dialog")
    classes_from_link = link.data("modal-class")
    if classes_from_link
      dialog.addClass classes_from_link

#$('body').on ', (event) ->
decko.slotReady (slot) ->
#  if slot.parent().is("#modal-container")
#    slot.parent().modal("show")
  # slot.find("._modal-link").on "click", (event) ->
  #   link = $(this)
  #   modal_slot = $(link.data("target"))
  #   dialog = modal_slot.find(".modal-dialog")
  #   dialog.attr("class", "modal-dialog")
  #   classes_from_link = link.data "modal-class"
  #   if classes_from_link
  #     dialog.addClass classes_from_link


  # this finds ._modal-slots and moves them to the end of the body
  # this allows us to render modal slots inside slots that call them and yet
  # avoid associated problems (eg nested forms and unintentional styling)
  # note: it deletes duplicate modal slots
  slot.find('._modal-slot').each ->
    mslot = $(this)
    if $.find("body #" + mslot.attr("id")).length > 1
      mslot.remove()
    else
      $("body").append mslot


modalSlot = ->
  slot = $("#modal-container > .card-slot")
  if slot.length > 0 then slot else createModalSlot()

createModalSlot = ->
  slot = $('<div/>', class: "card-slot")
  $("body").append(
    $('<div/>', id: "modal-container", class: "modal fade").append(slot)
  )
  slot

openModalIfPresent = (mslot) ->
  if mslot.find(".modal-content").html().length > 0
    mslot.modal("show")