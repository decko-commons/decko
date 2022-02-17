$(document).ready ->
  $('body').on 'keyup', 'input._nest-option-value', () ->
    nest.updatePreview()

  $('body').on "select2:select", '._nest-option-value', () ->
    nest.updatePreview()

  $('body').on "select2:select", "._nest-option-name", () ->
    nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), true)
    nest.setOptionValueField $(this), $(this).val()
    nest.updatePreview()

  $('body').on "select2:selecting", "._nest-option-name", () ->
    nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), false)

  $('body').on "select2:select", "._nest-option-name._new-row", () ->
    $(this).closest(".input-group").find(".input-group-prepend").removeClass("d-none")
    row =  $(this).closest("._nest-option-row")
    row.find("._nest-option-value").removeAttr("disabled")
    template = row.parent().find("._nest-option-row._template")
    $(this).removeClass("_new-row")
    nest.addRow(template)

  $('body').on "click", "._configure-items-button", () ->
    nest.addItemsOptions($(this))

  $('body').on 'click', 'button._nest-delete-option', () ->
    nest.removeRow $(this).closest("._nest-option-row")

$.extend nest,
  showTemplate: (elem) ->
    elem.removeClass("_template") #.removeClass("_#{name}-template").addClass("_#{name}")

  addRow: (template) ->
    double = template.clone(false)
    template.after(double)
    select_tag = template.find("select._nest-option-name")
    decko.initSelect2(select_tag)
    nest.showTemplate template

  removeRow: (row) ->
    name = row.find("._nest-option-name").val()
    nest.toggleOptionName(row.closest("._options-select"), name,false)
    row.remove()
    nest.updatePreview()

  addItemsOptions: (button) ->
    container = button.closest("._configure-items")
    next = container.clone(true)
    title = button.text()
    newtitle = title.substr(4)
    button.replaceWith($("<label>#{newtitle.charAt(0).toUpperCase() + newtitle.slice(1)}<label>"))
    nest.showTemplate container.find("._options-select._template")
    next.find("._configure-items-button").text(title.replace("item", "subitem"))
    container.after(next)
    nest.updatePreview()

  options: () ->
    options = []
    for ele in $("._options-select:not(._template")
      options.push nest.extractOptions($(ele))
    view = $("._view-select").val()
    if view.length > 0
      options[0].view = [view]
    level_options = options.map (opts) ->
                      nest.toNestSyntax(opts)

    level_options.join "|"

  # extract options for one item level
  extractOptions: (ele) ->
    options = {}
    nest.addOption(options, $(row)) for row in ele.find("._nest-option-row:not(.template)")
    options

  addOption: (options, row) ->
    val = row.find("._nest-option-value").val()
    return unless val? && val.length > 0

    name = row.find("._nest-option-name").val()
    if options[name]?
      options[name].push val
    else
      options[name] = [val]

  # make sure that each option name can only be selected once (except show and hide)
  toggleOptionName: (container, name, active) ->
    return true if name == "show" || name == "hide"
    for sel in container.find("._nest-option-name")
      if $(sel).val() != name
        $(sel).find("option[value=#{name}]").attr "disabled", active
      # $(sel).find("option[value=#{val}]").removeAttr "disabled"
      # decko.initSelect2($(sel))

  setOptionValueField: (optionNameEl, optionName) ->
    optionsRow = $(optionNameEl).closest("._nest-option-row")
    templates = optionsRow.closest("._nest-options").find("._templates")
    template = templates.find("._nest-option-template-#{optionName}")
    if template.length == 0
      template = templates.find("._nest-option-template-default")
    valueCol = optionsRow.find("._nest-option-value-col")
    valueCol.empty()

    valueField = template.clone(true)

    decko.initSelect2(valueField.find("select"))
    valueCol.append valueField

  toNestSyntax: (opts) ->
    str = []
    str.push "#{name}: #{values.join ', '}" for name, values of opts
    str.join "; "
