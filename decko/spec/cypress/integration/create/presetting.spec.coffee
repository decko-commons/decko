describe 'presetting', () ->
  before ->
    cy.login()

  specify "presetting content in url", ->
    cy.visit "/new/book?card[name]=HarryPotter&_author=JKRowling"
    cy.get("iframe.tox-edit-area__iframe")
    cy.contains("Submit").click()
    cy.visit "HarryPotter+author"
    cy.main_slot().should "contain", "JKRowling"

  specify "simple cardtype autoname", ->
    cy.ensure "Book+*type+*autoname", "Book_1"
    cy.delete "Book_1"
    cy.delete "Book_2"

    cy.visit "/new/book"
    cy.get("iframe.tox-edit-area__iframe")
    cy.contains("Submit").click()
    cy.expect_main_title "Book_1"
    cy.visit "/new/book"
    cy.get("iframe.tox-edit-area__iframe")
    cy.contains("Submit").click()
    cy.expect_main_title "Book_2"

    cy.delete "Book+*type+*autoname"

