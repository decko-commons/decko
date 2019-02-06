Cypress.Commands.add "visit_bridge", (card="A") =>
  cy.visit("/#{card}?view=edit")

Cypress.Commands.add "bridge", () =>
  cy.get(".bridge .bridge-main") #.as("bridge")

Cypress.Commands.add "bridge_sidebar", () ->
  cy.get(".bridge .bridge-sidebar") #.as("bridge-sidebar")

