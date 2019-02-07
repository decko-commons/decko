describe 'editing pointers', () ->
  before ->
    cy.login()
    cy.app("card/ensure", name: "friends+*right+*efault", type: "pointer")
    cy.app("card/ensure", name: "friends+*right+options", content: type: "search type")

  specify.only 'change with filtered list input', () ->
    cy.visit_bridge("joes")
    cy.get("._add-item-link").click()
    cy.get(".checkbox-side").first().click()
    cy.get("._add-selected").click()
    cy.get("._pointer-filtered-list")
      .should("contain", "Joe Admin")
