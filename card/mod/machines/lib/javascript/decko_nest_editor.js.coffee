$(document).ready ->
  $('body').on 'click', '._nest-field-toggle', () ->
    if $(this).is(':checked')
      decko.nest.addPlus()
    else
      decko.nest.removePlus()

  $('body').on 'keyup', 'input._nest-name', () ->
    repl = decko.nest.evalFieldOption $(this).val()
    new_val = $("._nest-preview").val().replace(/(?<=^\{\{)[^}|]*/, repl)
    decko.nest.updatePreview new_val

  $('body').on 'keyup', 'input._nest-option-value', () ->
    decko.nest.updatePreview()

  $('body').on "select2:select", "._nest-option-name", () ->
    decko.nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), true)
    decko.nest.updatePreview()

  $('body').on "select2:selecting", "._nest-option-name", () ->
    decko.nest.toggleOptionName($(this).closest("._options-select"), $(this).val(), false)

  $('body').on "select2:select", "._nest-option-name._new-row", () ->
    $(this).closest(".input-group").find(".input-group-prepend").removeClass("d-none")
    row =  $(this).closest("._nest-option-row")
    row.find("._nest-option-value").removeAttr("disabled")
    template = row.parent().find("._nest-option-row._template")
    $(this).removeClass("_new-row")
    decko.nest.addRow(template)

  $('body').on "click", "._configure-items-button", () ->
    decko.nest.addItemsOptions($(this))

  $('body').on 'click', 'button._nest-delete-option', () ->
    decko.nest.removeRow $(this).closest("._nest-option-row")

  $('body').on 'click', 'button._nest-apply', () ->
    decko.nest.apply($(this).data("tinymce-id"), $(this).data("nest-id"))

$.extend decko,
  nest:
    openEditor: (tinymce_id, nest_id) ->
      url = "/:update?view=nest_editor&nest_id=#{nest_id}&tinymce_id=#{tinymce_id}"
      slot = $(".bridge-sidebar > .card-slot")
      if slot[0]
        slot.reloadSlot "#{url}&slot[wrap]=overlay"
      else
        $.ajax
          url: "#{url}&slot[wrap]=modal"
          type: 'GET'
          success: (html) ->
            $(html).showAsModal($("##{tinymce_id}"))

    apply: (tinymce_id, nest_id) ->
      content =  $("._nest-preview").val()
      tinymce.get(tinymce_id).insertContent content

    showTemplate: (elem) ->
      elem.removeClass("_template") #.removeClass("_#{name}-template").addClass("_#{name}")

    updatePreview: (new_val) ->
      new_val = "{{#{decko.nest.name()}|#{decko.nest.options()}}}" unless new_val?
      $("._nest-preview").val new_val

    addRow: (template) ->
      select_tag = template.find("select")
      select_tag.select2("destroy")
      select_tag.removeAttr("data-select2-id")
      double = template.clone()
      #double = template.cloneSelect2(true, true)
      decko.initSelect2(select_tag)
      decko.nest.showTemplate template
      template.after(double)
      decko.initSelect2(double.find("select"))

    removeRow: (row) ->
      name = row.find("._nest-option-name").val()
      decko.nest.toggleOptionName(row.closest("._options-select"), name,false)
      row.remove()
      decko.nest.updatePreview()


    addItemsOptions: (button) ->
      container = button.closest("._configure-items")
      next = container.clone()
      title = button.text()
      button.replaceWith($("<h6>#{title.substr(9)}<h6>"))
      decko.nest.showTemplate container.find("._options-select._template")
      next.find("._configure-items-button").text(title.replace("items", "subitems"))
      container.after(next)
      decko.nest.updatePreview()

    name: () ->
      decko.nest.evalFieldOption $('input._nest-name').val()

    options: () ->
      options = []
      for ele in $("._options-select:not(._template")
        options.push decko.nest.extractOptions($(ele))

      options.map (opts) ->
        decko.nest.toNestSyntax(opts)
      .join "|"

    evalFieldOption: (name) ->
      if $('._nest-field-toggle').is(":checked") then "+#{name}" else name

    toNestSyntax: (opts) ->
      str = []
      str.push "#{name}: #{values.join ', '}" for name, values of opts
      str.join "; "

    # extract options for one item level
    extractOptions: (ele) ->
      options = {}
      decko.nest.addOption(options, $(row)) for row in ele.find("._nest-option-row:not(.template)")
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

    addPlus: () ->
      new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{+")
      decko.nest.updatePreview new_val
      $("._field-indicator .input-group-text").removeClass("d-none")
      $("._nest-name").addClass("border-left-0").removeClass("w-100")

    removePlus: () ->
      new_val = $("._nest-preview").val().replace(/^\{\{\+?/, "{{")
      decko.nest.updatePreview new_val
      $("._field-indicator .input-group-text").addClass("d-none")
      $("._nest-name").addClass("w-100").removeClass("border-left-0")
