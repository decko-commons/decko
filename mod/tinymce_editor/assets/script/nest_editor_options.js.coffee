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
    $(this).closest(".input-group").find(".d-none").removeClass("d-none")
    row =  $(this).closest("._nest-option-row")
    row.find("._nest-option-value").removeAttr("disabled")
    template = row.parent().find("._nest-option-row._template")
    $(this).removeClass("_new-row")
    nest.addRow template

  $('body').on "click", "._configure-items-button", () ->
    nest.addItemsOptions($(this))

  $('body').on 'click', 'button._nest-delete-option', () ->
    nest.removeRow $(this).closest("._nest-option-row")


$.extend nest,
  crypt: (text) =>
    salt = "dig"
    textToChars = (text) => text.split("").map((c) => c.charCodeAt(0))
    byteHex = (n) => ("0" + Number(n).toString(16)).substr(-2)
    applySaltToChar = (code) -> textToChars(salt).reduce(((a, b) => (a ^ b)), code)

    text.split("")
      .map(textToChars)
      .map(applySaltToChar)
      .map(byteHex)
      .join("")

  decrypt: (encoded) =>
    salt = "dig"
    textToChars = (text) => text.split("").map((c) => c.charCodeAt(0))
    applySaltToChar = (code) => textToChars(salt).reduce(((a, b) => (a ^ b)), code)
    encoded.match(/.{1,2}/g)
      .map((hex) => parseInt(hex, 16))
      .map(applySaltToChar)
      .map((charCode) => String.fromCharCode(charCode))
      .join("")

  story: {
    6: "2e030d4a0e0f0f1a0f184b",
    7: "2e0f0f1a0f184b",
    8: "220b040d4a03044a1e020f180f",
    9: "2d054a0e0f0f1a0f184b",
    10: "2f1c0f044a0e0f0f1a0f184b",
    11: "3d020b1e4a0e054a13051f4a0f121a0f091e4a1e054a0c03040e4a0e051d044a1e020f180f55",
    12: "290b010f55",
    13: "2b0603090f55",
    14: "380b0808031e1955",
    15: "3e020f180f4a03194a04051e0203040d4a0e051d044a1e020f180f4a081f1e4a080605050e464a1e050306464a1e0f0b18194a0b040e4a191d0f0b1e4b",
    16: "2e054a13051f4a0104051d4a1e020b1e4a220f18040b040e054a2905181e0f104a1f190f0e4a2e0f0901054a080b09014a03044a5b5f58594a1e054a02030e0f4a2b101e0f094a0d05060e55",
    17: "2e054a13051f4a0104051d4a1e020b1e4a2b1e060b041e03194a190b04014a080f090b1f190f4a031e4a0d051e4a1e180b1a1a0f0e4a03044a0b4a191f08031e0f074a0605051a55",
    18: "22051a0f4a13051f4d180f4a020b1c03040d4a0c1f044b",
    19: "234a190f0f4a1905070f1e0203040d4a19020304134b",
    20: "23194a031e4a0d05060e554b",
    21: "2e030b0705040e1955",
    22: "2502464a04054b4a33051f4a02031e4a180509014a08051e1e05074b",
    23: "391e0306064a0e030d0d03040d55",
    24: "33051f4a0e05044d1e4a0d031c0f4a1f1a4a0f0b19030613464a0e054a13051f55",
    25: "220b1c0f4a13051f4a1e18030f0e4a1e020f4a1a0309010b120f55",
    26: "25184a0e13040b07031e0f55",
    27: "2e030d4a05184a04051e4a1e054a0e030d464a1e020b1e4a03194a1e020f4a1b1f0f191e03050444",
    28: "2c050e03054a0f180d054a191f07",
    29: "23194a031e4a070f4a05184a03194a031e4a0d0f1e1e03040d4a02051e1e0f1855",
    30: "2b180f044d1e4a13051f4a0b0c180b030e4a050c4a070b0d070b55",
    31: "25184a080b0618050d1955",
    32: "2e054a13051f4a0104051d4a1e020b1e4a1e020f4a270b0d040b4a290b181e0b4a1d0b194a1d18031e1e0f044a1d031e024a2e0f090105554a270b13080f4a1e020f4a0518030d03040b064a0e180b0c1e4a03194a0e051d044a1e020f180f44",
    33: "2e054a13051f4a0104051d4a1e020b1e4a1e020f4a5b5b1e024a290507070b040e070f041e4a0d051e4a0605191e4a080f090b1f190f4a050c4a0b4a2e0f0901054a081f0d55",
    34: "210f0f1a4a0e030d0d03040d",
    35: "270b13080f4a13051f4d06064a0c03040e4a031e",
    36: "3d020b1e4a1d0306064a031e4a190b1355",
    37: "33051f4a19020b06064a020504051f184a13051f184a1902051c0f0655",
    38: "220b1c0f4a13051f4a1e02051f0d021e4a0b08051f1e4a02051d4a13051f4a1d0306064a0d0f1e4a051f1e4a050c4a020f180f55",
    39: "234a02051a0f4a13051f4a0818051f0d021e4a0b4a060b0e0e0f1844",
    40: "210f0f1a4a0e030d0d03040d464a234d06064a190f0f4a13051f4a05044a1e020f4a051e020f184a19031e0f44",
    41: "",
  },

  encryptStory: (originalStory) ->
    str = ""
    index = 6
    originalStory.forEach((s) ->
      console.log(s)
      str += "#{index}: \"#{nest.crypt(s)}\",\n"
      index += 1)
    console.log(str)

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
    levelCount = container.parent().find("._configure-items").length

    if levelCount > 5
      title = nest.decrypt(nest.story[levelCount])
      button.replaceWith("<label>Sub" + "sub".repeat(levelCount - 2) + "item options</label>")
    else
      title = button.text()
      newtitle = title.substr(4)
      button.replaceWith($("<label>#{newtitle.charAt(0).toUpperCase() + newtitle.slice(1)}</label>"))
      title = title.replace("item", "subitem")

    nest.showTemplate container.find("._options-select._template")
    rowTemplate = container.find("._nest-option-row._template")
    nest.addRow(rowTemplate)

    next.find("._configure-items-button").text(title)
    container.after(next)
    nest.updatePreview()

  options: () ->
    options = []
    view = $("._view-select").val()
    for ele in $("._options-select:not(._template")
      extractedOptions = nest.extractOptions($(ele), view)
      view = null  # view is for first level
      options.push extractedOptions


    level_options = options.map (opts) ->
                      nest.toNestSyntax(opts)
    level_options.join "|"

  # extract options for one item level
  extractOptions: (ele, view) ->
    options = {}
    if view? && view.length > 0
      options.view = [view]
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
    return true if !name? || name.length == 0 || name == "show" || name == "hide"
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
