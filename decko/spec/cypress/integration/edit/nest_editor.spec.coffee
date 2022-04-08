open_nest_editor = () ->
  cy.get("[title='Insert/edit nest']").click()

open_image_editor = () ->
  cy.contains("button", "Insert").click()
  cy.get("[title='Image...']").click()

nest_option_type = (section, row, name, value) ->
  cy.get("._options-select").eq(section)
    .find("select._nest-option-name").eq(row).select2(name)
  cy.get("._options-select").eq(section)
    .find("input._nest-option-value").eq(row)
    .type value

nest_option_select = (section, row, name, value) ->
  cy.get("._options-select").eq(section)
    .find("select._nest-option-name").eq(row).select2(name)
  cy.get("._options-select").eq(section)
    .find("select._nest-option-value").eq(row).select2(value)

type_nest = (text) ->
  cy.tinymce (ed, win) ->
    ed.focus()
    t = text.replace("{cursor}", "<span id='mymarker'>\u200b</span>")
    ed.insertContent(t)
    marker = win.jQuery(ed.getBody()).find('#mymarker')
    ed.selection.select(marker.get(0))
    marker.remove()
    ed.insertContent(" ")

describe 'nest editor', () ->
  before ->
    cy.ensure "nests", ""
    cy.login()
    # cy.clear_script_cache()

  specify "nest editor", () ->
    cy.visit_bridge "nests"
    open_nest_editor()
    cy.get("._view-select").select2("titled")

    cy.contains "options"
      .click()
    cy.get "input#nest_name"
      .type "NaNa", force: true
    cy.contains "button", "Add item options"
      .click()

    cy.contains "label", "Item options"
    cy.contains "button", "Add subitem options"

    cy.get("._options-select").eq(0).as("options")
    cy.get("._options-select").eq(1).as("itemoptions")

    nest_option_type 0, 0, "title", "T"
    nest_option_select 1, 0, "view", "bar"
    nest_option_select 1, 1, "show", "guide"
    cy.contains "Apply and Close"
      .click()
    cy.tinymce_content()
      .should "eq", "<p>{{ +NaNa|view: titled; title: T|view: bar; show: guide }}</p>"

    type_nest("{{handcrafted{cursor}|view: bar; title: T}}")
    open_nest_editor()
    cy.get("input#nest_name").should "have.value", "handcrafted"
      .clear().type("crafted")
    cy.get("select._view-select").should "have.value", "bar"
    cy.contains("options")
      .click()
    cy.get("input._nest-option-value").should "have.value", "T"
    cy.get("._nest-delete-option").first().click()
    nest_option_select 0, 0, "hide", "guide"
    cy.contains "Apply and Close"
      .click()
    cy.tinymce_content()
      .should "eq", "<p>{{ +NaNa|view: titled; title: T|view: bar; show: guide }}{{ crafted|view: bar; hide: guide }}</p>"

  specify "nest rules editor", () ->
    cy.delete "NaNa+*right+*help"
    cy.visit_bridge "nests"
    open_nest_editor()

    cy.get("._nest-editor").within () ->
      cy.contains "rules"
        .click()
      cy.get ".tab-pane-rules"
        .should "not.contain", "default"
        .contains ".alert", "nest name required"
        .should "be.visible"
      cy.get "input#nest_name"
        .type "NaNa{enter}", force: true
      cy.get ".tab-pane-rules .card-slot.nest_rules-view", timeout: 15000
        .should "contain", "default"
        .contains ".alert", "nest name required"
        .should "not.exist"

    cy.get("select._submit-on-select").eq(1).select2("All")
    cy.contains("a.edit-rule-link", "help").click()
    cy.contains("Define rule")
    cy.get(".rule-type-field").select2("PlainText")
    cy.get(":nth-child(2) > .card-editor > .editor > #card_content").type "help nana{enter}"
    cy.contains("All \"+NaNa\" cards on \"RichText\" cards").click()
    cy.contains("Save and Close").click()

#      cy.contains "undo", timeout: 10000
#      cy.get ".card-slot.RIGHT-Xhelp .form-control-feedback"
#        .should "contain", "All \"+NaNa\" cards"
#        .should "contain", "Applied!"
#
#      cy.get ".card-slot.RIGHT-Xhelp input#card_content"
#        .type "remove this{enter}"
#      cy.get ".card-slot.RIGHT-Xhelp"
#        .should "not.contain", "undo"
#      cy.contains("undo").click()
#      cy.get ".card-slot.RIGHT-Xhelp input#card_content", timeout: 10000
#        .should "have.value", "help nana"
#      cy.get ".card-slot.RIGHT-Xhelp"
#        .should "contain", "All \"+NaNa\" cards"
#        .should "not.contain", "undo"


    cy.visit "RichText+NaNa+*type plus right+*help"
    cy.expect_main_content "help nana"

  specify "nest image editor", () ->
    cy.visit_bridge "nests"
    open_image_editor()
    # cy.get(".modal ._nest-editor").within () ->
    cy.contains("select").click()
    cy.get("select._image-card-select").searchAndSelect2("*log", "*logo")
    cy.contains("options").click()
    cy.get("select._image-view-select").select2("titled")
    cy.get("select._image-size-select").select2("small")
    cy.contains("Apply and Close").click()
    cy.tinymce_content()
      .should "eq", "<p>{{ *logo | view: titled; size: small }}</p>"

    # TODO: figure out how to upload images

  specify "nest list editor", () ->
      cy.visit("new/nest_list")
      cy.get("._open-nest-editor").click()
      cy.contains "options"
        .click()
      cy.get "input#nest_name"
        .type "NaNa", force: true

      cy.contains "button", "Add item options"
        .click()
      cy.contains "button", "Add subitem options"
        .click()
      cy.get("._options-select").eq(0).as("options")
      cy.get("._options-select").eq(1).as("itemoptions")

      nest_option_type(0, 0, "title", "T")
      nest_option_select(1, 0, "show", "guide")

      cy.contains "Apply and Close"
        .click()

      cy.get("#pointer_item")
        .should "have.value", "NaNa"
      cy.get("#pointer_item_title")
        .should "have.value", "title: T|show: guide|"
        #.should "have.value", "title: T|view: bar; show: guide|view: bar"

      cy.get("#card_name")
        .type "A Nest List"
      cy.contains "Submit"
        .click()
      cy.main_slot()
        .should("not.contain", "Submitting")

      cy.visit("A Nest List?view=raw")
      # cy.contains "{{NaNa|title: T|view: bar; show: guide|view: bar}}"
      cy.contains "{{NaNa|title: T|show: guide|}}"
