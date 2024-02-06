describe "setting up", () =>
  beforeEach ->
    cy.clearCookies()
    cy.logout()
    #Cypress.Cookies.debug(true)
    #Cypress.Cookies.preserveOnce('session_id', 'remember_token')
    cy.delete "The Newber"


  after ->
    #cy.appEval "Card::Auth.simulate_setup_need! false"

  specify "set up admin account", ->
#    Cypress.Cookies.preserveOnce()
#    cy.appEval "Card::Auth.simulate_setup_need!"
#    cy.visit "/*signin"
#    cy.visit "/"
#    cy.main_slot()
#      .should "contain", "Welcome"
#    cy.contains("name").type "The Newber"
#    cy.field("*email").type "newb@decko.org"
#    cy.field("*password").type "newb_pass{enter}"
#    cy.contains "Set Up"
#      .click()
#
#    cy.visit("/The Newber+*roles")
#    cy.main_slot()
#      .should "contain", "Administrator"
#
#    cy.contains "Sign Out"
#      .click()
#
#    cy.login("newb@decko.org", "newb_pass")
#    cy.contains "The Newber"


