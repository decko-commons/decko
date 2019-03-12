describe 'autonaming', () ->
  before ->
    cy.login()
    cy.ensure "Book+*type+*autoname", "Book_1"

  specify "simple cardtype auotname", ->
    cy.visit "/new/book"
    cy.contains("Submit").click()
    cy.expect_main_title "Book_1"
    cy.visit "/new/book"
    cy.contains("Submit").click()
    cy.expect_main_title "Book_2"

