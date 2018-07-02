# TODO: use same slotReady approach as below
$(window).ready ->
  $('body').on 'hidden.bs.modal', (event) ->
    if $(event.target).attr('id') != 'modal-main-slot'
      modal_content = $(event.target).find('.modal-dialog > .modal-content')
      modal_content.empty()
      refresh_menu($(event.target).slot())

  $('._modal-slot').each ->
    openModalIfPresent $(this)

#$('body').on ', (event) ->
decko.slotReady (slot) ->
  $("._modal-slot").on "show.bs.modal", (event) ->
    link = $(event.target)
    dialog = $(this).find(".modal-dialog")
    dialog.attr("class", "modal-dialog")
    classes_from_link = link.data("modal-class")
    if classes_from_link
      dialog.addClass classes_from_link

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


openModalIfPresent = (mslot) ->
  if mslot.find(".modal-content").html().length > 0
    mslot.modal("show")