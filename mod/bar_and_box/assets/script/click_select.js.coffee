# TODO: move to list mod when possible
# (currently not because list mod comes before jquery)

$("body").on "click", "._click-multiselect-editor ._select-item", (event) ->
  $(this).closest("._select-item").toggleClass("selected")
  event.stopPropagation()

$("body").on "click", "._click-select-editor ._select-item", (event) ->
  selectEditor = $(this).closest("._click-select-editor")
  selectEditor.find(".selected").removeClass("selected")
  $(this).closest("._select-item").addClass("selected")
  event.stopPropagation()
