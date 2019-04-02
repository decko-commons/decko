open_nest_editor = () ->
  cy.get("[title='Insert/edit nest']").click()

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
    #cy.clear_script_cache()

  specify "nest editor", () ->
    cy.ensure "nests", ""
    cy.visit_bridge "nests"
    open_nest_editor()

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
    cy.contains("[data-dismiss=overlay]", "Close").click()

    type_nest("{{handcrafted{cursor}|view: special}}")
    open_nest_editor()
    cy.get("input#nest_name").should "have.value", "handcrafted"
      .clear().type("crafted")
    cy.get("input._nest-option-value").should "have.value", "special"
    cy.get("._nest-delete-option").first().click()
    nest_option 0, 0, "hide", "H"
    cy.contains "Apply"
      .click()
    cy.tinymce_content()
      .should "eq", "<p>{{crafted|hide: H}}{{Na|view: titled; title: T|view: bar}}</p>"

  specify.only "nest lrules editor", () ->
    cy.ensure "nests", ""
    cy.delete "NaNa+*right+*help"
    cy.visit_bridge "nests"
    open_nest_editor()

    cy.get(".nest_editor-view").within () ->
      cy.contains "rules"
        .click()
      cy.get "#Xupdate-rule.tab-pane"
        .should "not.contain", "default"
        .contains ".alert", "nest name required"
        .should "be.visible"
      cy.get "#nest_name"
        .type "NaNa"
      cy.get "#Xupdate-rule.tab-pane"
        .should "contain", "default"
        .contains ".alert", "nest name required"
        .should "not.be.visible"

      cy.get ".card-slot.RIGHT-Xhelp input#card_content"
        .type "help nana"
      cy.get ".card-slot.RIGHT-Xhelp .form-control-feedback"
        .should "contain", "undo"
        .should "contain", "All \"+NaNa\" cards"
        .should "contain", "Applied!"

      cy.get ".card-slot.RIGHT-Xhelp input#card_content"
        .type "remove this"
      cy.contains("undo").click()

      cy.get ".card-slot.RIGHT-Xhelp input#card_content"
        .should "have.value", "help nana"
      cy.get ".card-slot.RIGHT-Xhelp"
        .should "contain", "All \"+NaNa\" cards"
        .should "not.contain", "undo"


    cy.visit "NaNa+*right+*help"
    cy.expect_main_content "help nana"






