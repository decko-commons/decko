$(document).ready ->
  $('body').on 'click', '._nest-field-toggle', () ->
    if $(this).is(':checked')
      nest.addPlus()
    else
      nest.removePlus()

  $('body').on 'keyup', 'input._nest-name', () ->
    name = $(this).val()
    repl = nest.evalFieldOption name
    new_val = $("._nest-preview").val().replace(/^\{\{[^}|]*/, "{{" + repl)
    nest.updatePreview new_val

    clearTimeout(nestNameTimeout) if nestNameTimeout
    nestNameTimeout = setTimeout nest.updateRulesTab, 1000



$.extend nest,
  name: () ->
    nest.evalFieldOption $('input._nest-name').val()

  evalFieldOption: (name) ->
    if nest.isField() then "+#{name}" else name

  isField: ->
    $('._nest-field-toggle').is(":checked")

  addPlus: () ->
    new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{+")
    nest.updatePreview new_val
    $(".input-group.hide-prefix").removeClass("hide-prefix").addClass("show-prefix")

  removePlus: () ->
    new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{")
    nest.updatePreview new_val
    $(".input-group.show-prefix").removeClass("show-prefix").addClass("hide-prefix")

  updateRulesTab: () ->
    name = $("input._nest-name").val()
    if name? && name.length > 0
      card = if nest.isField() then "#{name}+*right" else "#{name}+*self"
      url = decko.path "#{card}?view=nest_rules"
      $("._empty-nest-name-alert:not(.d-none)").addClass("d-none")
      $("#Xupdate-rule > .card-slot").reloadSlot url
    else
      $("#Xupdate-rule > .card-slot").empty()
      $("._empty-nest-name-alert").removeClass("d-none")

