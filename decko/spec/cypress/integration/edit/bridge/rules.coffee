describe 'rules tab', () ->
  before ->
    cy.login()

  beforeEach ->
    cy.visit_bridge()

  specify 'no set selected', () ->
    cy.bridge_sidebar().get('.nav-tabs a:last').click()
    cy.bridge_sidebar().el("structure-pill").click()
    cy.tinymce_type "new structure"
    cy.el("submit-overlay ").click()

