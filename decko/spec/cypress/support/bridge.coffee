Cypress.Commands.add "visit_bridge", (card="A", tab) =>
  url = "/#{card}/bridge"
  url += "&bridge_tab[#{tab}]" if tab
  cy.visit(url)

Cypress.Commands.add "bridge", () =>
  cy.get(".bridge .bridge-main") #.as("bridge")

Cypress.Commands.add "bridge_sidebar", () ->
  cy.get(".bridge .bridge-sidebar") #.as("bridge-sidebar")

