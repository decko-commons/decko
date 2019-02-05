describe "/*signin", () =>
  before ->
    cy.clearCookies()
    cy.logout()

  beforeEach ->
    cy.visit "/*signin"

  it "links to /new/Sign_up", ->
    cy.contains "or sign up!"
      .should "have.attr", "href", "/new/Sign_up"

  it "links to reset password", ->
    cy.contains "RESET PASSWORD"
      .should "have.attr", "href", "/*signin?view=edit_content"

  it "requires email", ->
    cy.get("form").contains("Sign in").click()
    cy.get ".card-notice"
      .should "contain", "email can't be blank"

  it "requires password", ->
    cy.get "[name='card[subcards][+*email][content]']"
      .type "joe@admin.com{enter}"
    cy.get ".card-notice"
      .should "contain", "password can't be blank"

  it "requires valid email and password", ->
    cy.get "[name='card[subcards][+*email][content]']"
      .type "joe@admin.com"
    cy.get "[name='card[subcards][+*password][content]']"
      .type "invalid{enter}"
    cy.get ".card-notice"
      .should "contain", "Wrong password"

  it "navigates to '/' on successful signin", ->
    cy.get "[name='card[subcards][+*email][content]']"
      .type "joe@admin.com"
    cy.get "[name='card[subcards][+*password][content]']"
      .type "joe_pass{enter}"
    cy.hash().should "eq", ""
