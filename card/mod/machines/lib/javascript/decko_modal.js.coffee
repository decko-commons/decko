# TODO: use same slotReady approach as below
$(window).ready ->
  $('body').on 'hidden.bs.modal', (event) ->
    if $(event.target).attr('id') != 'modal-main-slot'
      modal_content = $(event.target).find('.modal-dialog > .modal-content')
      modal_content.empty()
      refresh_menu($(event.target).slot())

#$('body').on ', (event) ->
decko.slotReady (_slot) ->
  $("._modal-slot").on "show.bs.modal", ->
    link = $(event.target)
    dialog = $(this).find(".modal-dialog")
    dialog.attr("class", "modal-dialog")
    classes_from_link = link.data("modal-class")
    if classes_from_link
      dialog.addClass classes_from_link