describe 'presetting', () ->
  before ->
    cy.login()

  specify "simple cardtype autoname", ->
    cy.ensure "Book+*type+*autoname", "Book_1"
    cy.delete "Book_1"
    cy.delete "Book_2"

    cy.visit "/new/book"
    cy.contains("Submit").click()
    cy.expect_main_title "Book_1"
    cy.visit "/new/book"
    cy.contains("Submit").click()
    cy.expect_main_title "Book_2"

  specify "presetting content in url", ->
    cy.delete "Book+*type+*autoname"
    cy.visit "/new/book?card[name]=HarryPotter&_author=JKRowling"
    cy.contains("Submit").click()
    cy.visit "HarryPotter+author"
    cy.main_slot().should "contain", "JKRowling"

