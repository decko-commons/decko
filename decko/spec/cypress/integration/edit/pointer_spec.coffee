describe 'editing pointers', () ->
  before ->
    cy.login()

  specify.only 'change with filtered list input', () ->
    cy.visit_bridge("joes")
    cy.get("._add-item-link").click()
    cy.get(".checkbox-side").first().click()
    cy.get("._add-selected").click()
    cy.get("._pointer-filtered-list")
      .should("contain", "Joe Admin")
