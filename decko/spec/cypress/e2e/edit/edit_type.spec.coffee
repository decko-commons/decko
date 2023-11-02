describe 'edit type', () ->
  before ->
    cy.login()
    cy.ensure "ice", type: 'basic'

  beforeEach ->
    cy.login()

  specify "edit type in board", () ->
    cy.visit_board("ice")
    cy.slot("ice", "edit_type_row").el("edit-link").click(force: true)
    cy.select2_by_name("card[type]", "Book")

    # wait for type form to disappear

    cy.board().should "contain", "+author"
    #cy.el("submit-modal").click()
    cy.contains("Save and Close").click()
    # cy.get(".board").should "not.visible", wait: 10000
    cy.main_slot().should "contain", "+author"

  specify "edit type for new card", () ->
    cy.delete "newcard"
    cy.visit "newcard"
    cy.select2_by_name("card[type]", "PlainText")
    cy.get("textarea[name='card[content]'][rows=5]").type "snug"
    cy.contains("Submit").click()
    cy.main_slot().should "contain", "snug"

  specify "edit type for rule", () ->
    cy.visit_board()
    cy.board_sidebar().find('.nav-tabs a:last').click()
    cy.board_sidebar().select2_by_name("mark", "The card \"A\"")
    cy.board_sidebar().contains("templating").click()
    cy.board_sidebar().contains("template for new cards").click()
    cy.get("input[value='*all+*default']").check()
    cy.select2_by_name("card[type]", "PlainText")
    cy.get("input[name='card[content]']")
