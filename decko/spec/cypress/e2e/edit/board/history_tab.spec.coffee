 describe 'history tab', () ->
  before ->
    cy.login()
    cy.ensure "no history", type: 'basic'
    cy.ensure "no history", content: "add history"

  beforeEach ->
    cy.login()
    cy.visit_board('no history')
    cy.board_sidebar().find('.nav-tabs a').eq(2).click()

  specify 'changes appear in the pills list', () ->
    cy.contains("Joe Admin less than a minute ago")
    cy.delete 'no history'