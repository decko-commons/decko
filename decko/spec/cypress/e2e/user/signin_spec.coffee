describe "/*signin", () =>
  beforeEach ->
    cy.clearCookies()
    cy.logout()

  beforeEach ->
    cy.visit "/*signin"

  it "links to /new/Sign_up", ->
    cy.contains "or sign up!"
      .should "have.attr", "href", "/new/Sign_up"

  it "links to reset password", ->
    cy.contains "Reset password"
      .should "have.attr", "href", "/*signin/edit?slot%5Bhide%5D%5B%5D=board_link"

  it "requires email", ->
    cy.get("form").contains("Sign in").click()
    cy.get ".card-notice"
      .should "contain", "email can't be blank"

  it "requires password", ->
    cy.field "*email"
      .type "joe@admin.com{enter}"
    cy.get ".card-notice"
      .should "contain", "password can't be blank"

  it "requires valid email and password", ->
    cy.field "*email"
      .type "joe@admin.com"
    cy.field "*password"
      .type "invalid{enter}"
    cy.get ".card-notice"
      .should "contain", "Wrong password"

  it "navigates to '/' on successful signin", ->
    cy.field "*email"
      .type "joe@admin.com"
    cy.field "*password"
      .type "joe_pass{enter}"
    cy.hash().should "eq", ""
