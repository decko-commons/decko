$(document).ready ->
  $('body').on 'keyup', 'input._nest-option-value', () ->
    nest.updatePreview()

  $('body').on "select2:select", "._nest-option-name", () ->
    nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), true)
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
    select_tag = template.find("select")
    select_tag.select2("destroy")
    select_tag.removeAttr("data-select2-id")
    double = template.clone()
    #double = template.cloneSelect2(true, true)
    decko.initSelect2(select_tag)
    nest.showTemplate template
    template.after(double)
    decko.initSelect2(double.find("select"))

  removeRow: (row) ->
    name = row.find("._nest-option-name").val()
    nest.toggleOptionName(row.closest("._options-select"), name,false)
    row.remove()
    nest.updatePreview()

  addItemsOptions: (button) ->
    container = button.closest("._configure-items")
    next = container.cloneSelect2(true)
    title = button.text()
    button.replaceWith($("<h6>#{title.substr(9)}<h6>"))
    nest.showTemplate container.find("._options-select._template")
    next.find("._configure-items-button").text(title.replace("items", "subitems"))
    container.after(next)
    nest.updatePreview()

  options: () ->
    options = []
    for ele in $("._options-select:not(._template")
      options.push nest.extractOptions($(ele))

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

  toggleOptionName: (container, name, active) ->
    return true if name == "show" || name == "hide"
    for sel in container.find("._nest-option-name")
      if $(sel).val() != name
        $(sel).find("option[value=#{name}]").attr "disabled", active
      # $(sel).find("option[value=#{val}]").removeAttr "disabled"
      decko.initSelect2($(sel))

  toNestSyntax: (opts) ->
    str = []
    str.push "#{name}: #{values.join ', '}" for name, values of opts
    str.join "; "
