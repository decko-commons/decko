describe 'editing pointers', () ->
  before ->
    cy.login()
    #cy.clear_machine_cache()
    #cy.app("card/ensure", name: "friends+*right+*efault", type: "pointer")
    #cy.app("card/ensure", name: "friends+*right+options", content: type: "search type")

  specify 'change with filtered list input', () ->
    cy.visit_bridge("joes")
    cy.get("._add-item-link").click()
    cy.get(".checkbox-side").first().click()
    cy.get("._add-selected").click()
    cy.get("._pointer-filtered-list")
      .should("contain", "Joe Admin")

  specify.only 'create with filtered list input', () ->
    cy.app("card/ensure", name: "friends+*right+*input", type: "phrase", content: "filtered list")
    cy.visit("/Joe User+friends")
    cy.get("._add-item-link").click()
    cy.contains("Select Item")
    cy.contains("button", "Add filter").click()
    cy.contains("a","Keyword").click()
    cy.get("[name='filter[name]']").type("Joe{enter}").then ->
      cy.get("._search-checkbox-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")
      cy.contains(/select\s+3\s+following/)
      cy.get("input._select-all").click()
      cy.get("._add-selected").click()
      cy.get("._pointer-filtered-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")

      cy.get("._add-item-link").click()
      cy.get("input[name='Big Brother']").click()
      cy.get("._add-selected").click()
      cy.get("._pointer-filtered-list")
        .should("contain", "Joe Camel")
        .should("contain", "Big Brother")
        .should("not.contain", "u1")




