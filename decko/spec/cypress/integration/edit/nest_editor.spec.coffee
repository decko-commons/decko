open_nest_editor = () ->
  cy.get("[title='Insert/edit nest']").click()

open_image_editor = () ->
  cy.contains("button", "Insert").click()
  cy.get("[title='Image...']").click()

nest_option = (section, row, name, value) ->
  cy.get("._options-select").eq(section)
    .find("select._nest-option-name").eq(row).select2(name)
  cy.get("._options-select").eq(section)
    .find("input._nest-option-value").eq(row)
    .type value

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
    cy.login()
    # cy.clear_script_cache()

  specify "nest editor", () ->
    cy.ensure "nests", ""
    cy.visit_bridge "nests"
    open_nest_editor()
    cy.contains "options"
      .click()
    cy.get "#nest_name"
      .type "NaNa"
    cy.contains "button", "Configure items"
      .click()

    cy.contains "h6", "items"
    cy.contains "button", "Configure subitems"

    cy.get("._options-select").eq(0).as("options")
    cy.get("._options-select").eq(1).as("itemoptions")

    nest_option(0, 1, "title", "T")
    nest_option(1, 1, "show", "IS")
    cy.contains "Apply"
      .click()
    cy.tinymce_content()
      .should "eq", "<p>{{+NaNa|view: titled; title: T|view: bar; show: IS}}</p>"

    cy.get "#nest_name"
      .clear().type "Na"
    cy.contains "Apply"
      .click()

    cy.get("@itemoptions")
      .find("._nest-delete-option").eq(1).click()
    cy.get("._nest-field-toggle").uncheck()
    cy.contains "Apply"
      .click()
    cy.tinymce_content()
      .should "eq", "<p>{{Na|view: titled; title: T|view: bar}}</p>"
    cy.contains("[data-bs-dismiss=overlay]", "Close").click()

    type_nest("{{handcrafted{cursor}|view: special}}")
    open_nest_editor()
    cy.contains("options")
      .click()
    cy.get("input#nest_name").should "have.value", "handcrafted"
      .clear().type("crafted")
    cy.get("input._nest-option-value").should "have.value", "special"
    cy.get("._nest-delete-option").first().click()
    nest_option 0, 0, "hide", "H"
    cy.contains "Apply"
      .click()
    cy.tinymce_content()
      .should "eq", "<p>{{crafted|hide: H}}{{Na|view: titled; title: T|view: bar}}</p>"

  specify "nest rules editor", () ->
    cy.ensure "nests", ""
    cy.delete "NaNa+*right+*help"
    cy.visit_bridge "nests"
    open_nest_editor()

    cy.get(".nest_editor-view").within () ->
      cy.contains "rules"
        .click()
      cy.get ".tab-pane-rules"
        .should "not.contain", "default"
        .contains ".alert", "nest name required"
        .should "be.visible"
      cy.get "#nest_name"
        .type "NaNa{enter}"
      cy.get ".tab-pane-rules .card-slot.nest_rules-view", timeout: 15000
        .should "contain", "default"
        .contains ".alert", "nest name required"
        .should "not.exist"

      cy.get ".card-slot.RIGHT-Xhelp input#card_content"
        .type "help nana{enter}"
      cy.contains "undo", timeout: 10000
      cy.get ".card-slot.RIGHT-Xhelp .form-control-feedback"
        .should "contain", "All \"+NaNa\" cards"
        .should "contain", "Applied!"

      cy.get ".card-slot.RIGHT-Xhelp input#card_content"
        .type "remove this{enter}"
      cy.get ".card-slot.RIGHT-Xhelp"
        .should "not.contain", "undo"
      cy.contains("undo").click()
      cy.get ".card-slot.RIGHT-Xhelp input#card_content", timeout: 10000
        .should "have.value", "help nana"
      cy.get ".card-slot.RIGHT-Xhelp"
        .should "contain", "All \"+NaNa\" cards"
        .should "not.contain", "undo"


    cy.visit "RichText+NaNa+*type plus right+*help"
    cy.expect_main_content "help nana"

  specify "nest image editor", () ->
    cy.ensure "nests", ""
    cy.visit_bridge "nests"
    open_image_editor()
    cy.get(".modal")
      .should "contain", "nests+image01"
      .should "contain", "Add Image"

    # TODO: figure out how to attach images

  specify "nest list editor", () ->
      cy.visit("new/nest_list")
      cy.get("._open-nest-editor").click()
      cy.contains "options"
        .click()
      cy.get "#nest_name"
        .type "NaNa"

      cy.contains "button", "Configure items"
        .click()
      cy.contains "button", "Configure subitems"
        .click()
      cy.get("._options-select").eq(0).as("options")
      cy.get("._options-select").eq(1).as("itemoptions")

      nest_option(0, 0, "title", "T")
      nest_option(1, 1, "show", "IS")

      cy.contains "Apply"
        .click()

      cy.get("#pointer_item")
        .should "have.value", "NaNa"
      cy.get("#pointer_item_title")
        .should "have.value", "title: T|view: bar; show: IS|view: bar"

      cy.get("#card_name")
        .type "A Nest List"
      cy.contains "Submit"
        .click()
      cy.main_slot()
        .should("not.contain", "Submitting")

      cy.visit("A Nest List?view=raw")
      cy.contains "{{NaNa|title: T|view: bar; show: IS|view: bar}}"





