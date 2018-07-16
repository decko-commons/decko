# TODO: use same slotReady approach as below
$(window).ready ->
  $('body').on 'ajax:success', '._modal-slotter', (event, data, c, d) ->
  unless event.slotSuccessful
    $this = $(this)
    modalSlot.slotSuccess data, $this.hasClass("_slotter-overlay")
    if $this.hasClass "close-modal"
      $this.closest('.modal').modal('hide')
    # should scroll to top after clicking on new page
    if $this.hasClass "card-paging-link"
      slot_top_pos = $this.slot().offset().top
      $("body").scrollTop slot_top_pos
    if $this.data("update-foreign-slot")
      $slot = $this.find_slot $this.data("update-foreign-slot")
      $slot.updateSlot $this.data("update-foreign-slot-url")

    event.slotSuccessful = true

  $('body').on 'ajax:error', '.slotter', (event, xhr) ->
    $(this).slotError xhr.status, xhr.responseText


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


modalContainer = ->
  modal_container = $("#modal-container")
  unless modal_container.length > 0
    modal_container = $('<div id="modal-container" class="modal fade">')
    $("body").append modal_container
    modal_container.append $('<div class="card-slot">')
  modal_container

modalSlot = ->
  modalContainer().find(".card-slot")


openModalIfPresent = (mslot) ->
  if mslot.find(".modal-content").html().length > 0
    mslot.modal("show")