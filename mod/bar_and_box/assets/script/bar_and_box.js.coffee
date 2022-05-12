$(window).ready ->
  $("body").on "click", ".bar-menu", (e) ->
    e.stopImmediatePropagation()

  $(document).on 'click', "._card-link", ->
    window.location = decko.path $(this).data("cardLinkName")

  $("body").on "click", "._click-select-editor ._select-item", (event) ->
    selectEditor = $(this).closest("._click-select-editor")
    selectEditor.find(".selected").removeClass("selected")
    $(this).closest("._select-item").addClass("selected")
    event.stopPropagation()

  $("body").on "click", "._click-multiselect-editor ._select-item", (event) ->
    $(this).closest("._select-item").toggleClass("selected")
    event.stopPropagation()

  $('body').on 'click', "._card-link a", (event)->
    if $(this).hasClass "over-card-link"
      # don't count as bar click
      event.stopPropagation()
    else
      # don't follow original link
      event.preventDefault()
