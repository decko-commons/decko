nestNameTimeout = null

$(document).ready ->
  toggle = false;
  $('body').on 'click', '._nest-field-toggle', () ->
    if $(this).is(':checked')
      nest.addPlus()
    else
      nest.removePlus()
    if toggle
      nest.addPlus()
    else
      nest.removePlus()
    toggle = !toggle

  $('body').on 'input', 'input._nest-name', (event) ->
    nest.nameChanged()

    unless event.which == 13
      clearTimeout(nestNameTimeout) if nestNameTimeout
      nestNameTimeout = setTimeout (-> nest.updateNameRelatedTabs()), 700

  $('body').on 'keydown', 'input._nest-name', (event) ->
    if event.which == 13
      clearTimeout(nestNameTimeout) if nestNameTimeout
      nest.updateNameRelatedTabs()

$.extend nest,
  name: () ->
    nest.evalFieldOption $('input._nest-name').val()

  nameChanged: () ->
    new_val = $("._nest-preview").val().replace(/^\{\{[^}|]*/, "{{" + nest.name())
    nest.updatePreview new_val

  evalFieldOption: (name) ->
    if nest.isField() then "+#{name}" else name

  isField: ->
    $('.show-prefix > ._field-indicator').length > 0

  addPlus: () ->
    new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{+")
    nest.updatePreview new_val
    $(".input-group.hide-prefix").removeClass("hide-prefix").addClass("show-prefix")

  removePlus: () ->
    new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{")
    nest.updatePreview new_val
    $(".input-group.show-prefix").removeClass("show-prefix").addClass("hide-prefix")

  rulesTabSlot: () ->
    $("._nest-editor .tab-pane-rules > .card-slot")

  contentTabSlot: () ->
    $("._nest-editor .tab-pane-content > .card-slot")

  tabPanel: ()  ->
    $("._nest-editor .tab-panel")

  emptyNameAlert: (show) ->
    if show
      $("._empty-nest-name-alert").removeClass("d-none")
    else
      $("._empty-nest-name-alert:not(.d-none)").addClass("d-none")

  updateNameRelatedTabs: () ->
    if nest.name().length > 0
      nest.tabPanel().show()
    else
      nest.tabPanel().hide()
    nest.updateRulesTab()
    nest.updateContentTab()

  updateContentTab: () ->
    $contentTab = nest.contentTabSlot()
    if $contentTab.length > 0
      url = decko.path "#{nest.fullName()}?view=nest_content"
      nest.updateNameDependentSlot($contentTab, url)

  updateRulesTab: () ->
    $rulesTab = nest.rulesTabSlot()
    url = decko.path "#{nest.setNameForRules()}?view=nest_rules"
    nest.updateNameDependentSlot($rulesTab, url)

  updateNameDependentSlot: ($slot, url) ->
    name = $("input._nest-name").val()
    if name? && name.length > 0
      nest.emptyNameAlert(false)
      $slot.reloadSlot url
    else
      $slot.clearSlot()
      nest.emptyNameAlert(true)

  fullName: () ->
    input = $('input._nest-name')
    nest_name = input.val()
    if nest.isField() and input.attr("data-left-name")
      "#{input.attr("data-left-name")}+#{nest_name}"
    else
      nest_name

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


