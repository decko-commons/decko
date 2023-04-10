Cypress.Commands.add "visit_board", (card="A", tab) =>
  url = "/#{card}/board"
  url += "&board_tab[#{tab}]" if tab
  cy.visit(url)

Cypress.Commands.add "board", () =>
  cy.get(".board .board-main") #.as("board")

Cypress.Commands.add "board_sidebar", () ->
  cy.get(".board .board-sidebar") #.as("board-sidebar")

