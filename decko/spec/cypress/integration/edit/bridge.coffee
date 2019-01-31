describe 'engage tab', () ->
  before ->
    cy.login()
    cy.retype("A", "Basic")

  specify 'Save updates main slot', () ->
    cy.visit_bridge()
    cy.tinymce_type "new content"
    cy.el("save").click()
    cy.el("close-modal").click()
    cy.contains("new content")

  it "updates non-main origin slot after 'save and close'", () ->
    cy.visit("/")

    cy.slot("menu").find(".card-menu > a").click(force: true).then ->
      cy.tinymce_type("fruit pants")
      cy.el("submit-modal").click()
        .slot("menu").should("contain", "fruit pants")
        .slot("home").should("not.contain", "fruit pants")

  it "updates non-main origin slot after 'save'", () ->
    cy.visit("/")

    cy.slot("menu").find(".card-menu > a").click(force: true).then ->
      cy.tinymce_type("function snug")
      cy.el("save").click()
      cy.el("close-modal").click()
      cy.slot("menu").should("contain", "function snug")
        .slot("home").should("not.contain", "function snug")

  it "updates origin slot after name change", () ->
    cy.visit_bridge()
    cy.slot("a", "edit_name_row").el("edit-link").click(force: true)
    cy.get(".name-editor > input[name='card[name]']").clear().type("XY")
    cy.get("button.renamer").click().click()
    cy.el("close-modal").click()

    cy.expect_main_title("XY")

    cy.rename("XY", "A")

  it "updates origin slot after type change", () ->
    cy.visit_bridge()
    cy.slot("a", "edit_type_row").el("edit-link").click(force: true)
    cy.get(".type-editor").select2("card[type]", "Book")
    cy.el("close-modal").click()

    cy.expect_main_content("+author")

