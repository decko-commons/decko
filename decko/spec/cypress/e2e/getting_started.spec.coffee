describe 'getting started', () ->
  beforeEach ->
    cy.login()

  specify.skip "configure skin", ->
    cy.update ":all+:style", content: "yeti skin"
    cy.visit("/")
    cy.contains("Getting started").click()
    cy.contains("Configure skin").click()
    cy.expect_main_title("*all+*style")
    cy.expect_main_content("yeti skin")
    cy.main_slot().click_edit()
    cy.contains("cosmo skin").click()
    cy.el("submit-modal").click()
    cy.expect_main_content("cosmo skin")



