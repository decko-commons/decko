nestNameTimeout = null

$(document).ready ->
  $('body').on 'click', '._nest-field-toggle', () ->
    if $(this).is(':checked')
      nest.addPlus()
    else
      nest.removePlus()

  $('body').on 'input', 'input._nest-name', (event) ->
    nest.nameChanged()

    unless event.which == 13
      clearTimeout(nestNameTimeout) if nestNameTimeout
      nestNameTimeout = setTimeout nest.updateRulesTab, 700

  $('body').on 'keydown', 'input._nest-name', (event) ->
    if event.which == 13
      clearTimeout(nestNameTimeout) if nestNameTimeout
      nest.updateRulesTab()

$.extend nest,
  name: () ->
    nest.evalFieldOption $('input._nest-name').val()

  nameChanged: () ->
    new_val = $("._nest-preview").val().replace(/^\{\{[^}|]*/, "{{" + nest.name())
    nest.updatePreview new_val

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

  rulesTabSlot: () ->
    $("._nest-editor .tab-pane-rule > .card-slot")

  emptyNameAlert: (show) ->
    if show
      $("._empty-nest-name-alert").removeClass("d-none")
    else
      $("._empty-nest-name-alert:not(.d-none)").addClass("d-none")

  updateRulesTab: () ->
    name = $("input._nest-name").val()
    $rulesTab = nest.rulesTabSlot()

    if name? && name.length > 0
      url = decko.path "#{nest.setNameForRules()}?view=nest_rules"
      nest.emptyNameAlert(false)
      $rulesTab.reloadSlot url
    else
      $rulesTab.clearSlot()
      nest.emptyNameAlert(true)

  #  set in the sense of card set
  setNameForRules: () ->
    input = $('input._nest-name')
    nest_name = input.val()
    if nest.isField()
      if input.attr("data-left-type")
        "#{input.attr("data-left-type")}+#{nest_name}+*type plus right"
      else
        "#{nest_name}+*right"
    else
      return  "#{nest_name}+*self"


