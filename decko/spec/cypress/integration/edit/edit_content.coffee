describe 'edit content', () ->
  before ->
    cy.login()

  specify "edit content modal", () ->
    cy.visit("/A?view=edit_content")

