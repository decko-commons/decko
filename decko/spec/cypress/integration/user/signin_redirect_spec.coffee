describe "redirect to signin page", () =>
  before ->
    cy.clearCookies()
    cy.logout()

  beforeEach ->
    cy.visit "/42"

  specify "edit modal ", ->
    cy.main_slot().click_edit()
    cy.get(".modal-content")
      .should "contain", "Sorry!"
    cy.get(".modal-content a.signin-link")
      .click(force: true)
    cy.get(".modal")
    cy.field "*email"
      .type "joe@admin.com"
    cy.field "*password"
      .type "joe_pass{enter}"
    cy.get(".modal .content-editor")
