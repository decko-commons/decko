describe 'engage tab', () ->
  before ->
    cy.login()

  beforeEach ->
    cy.visit_bridge("Joe Admin")

  specify 'change email', () ->
    cy.bridge_sidebar().get('.nav-tabs a:first').click()
    cy.el("detail-pill").click()
    cy.get(".SELF-joe_admin-Xaccount-Xemail.editable-view a.edit-link").click()
    cy.get("input.d0-card-content").clear().type("joee@admin.com")
    cy.get(".SELF-joe_admin-Xaccount-Xemail.editable-view")
      .should("contain", "joee@admin.com")
    cy.get(".SELF-joe_admin-Xaccount-Xemail.editable-view a.edit-link").click()
    cy.get("input.d0-card-content").type("joe@admin.com")

