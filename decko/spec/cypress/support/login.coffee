Cypress.Commands.add "login", (email="joe@admin.com", password="joe_pass") =>
  cy.request
    method: "POST",
    url: "/update/*signin",
    body:
      card:
        subcards:
          "+*email": { content: email }
          "+*password": { content: password }
