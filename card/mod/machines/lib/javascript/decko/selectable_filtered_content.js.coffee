$(window).ready ->

  # TODO: generalize so this works with item views other than bar
  $("body").on "click", "._selectable-filtered-content .bar-body", (e) ->
    item = $(this)
    name = item.slot().data("card-name")
    container = item.closest("._selectable-filtered-content")
    input = $(container.data("input-selector"))
    input.val name
    item.closest('.modal').modal('hide')
    e.preventDefault()
    e.stopPropagation()
