describe 'rules tab', () ->
  before ->
    cy.login()

  beforeEach ->
    cy.visit_bridge()

  specify 'no set selected', () ->
    cyd.get('.follow-link').click()
    cy.contains("following")
    cy.contains("1 follower")
    cy.get(".follow-link").click()
    cy.contains("follow")
    cy.contains("0 follower")
