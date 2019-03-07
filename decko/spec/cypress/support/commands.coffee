# ***********************************************
# This example commands.js shows you how to
# create various custom commands and overwrite
# existing commands.
#
# For more comprehensive examples of custom
# commands please read more here:
# https://on.cypress.io/custom-commands
# ***********************************************
#
#
# -- This is a parent command --
# Cypress.Commands.add("login", (email, password) => { ... })
#
#
# -- This is a child command --
# Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
#
#
# -- This is a dual command --
# Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
#
#
# -- This is will overwrite an existing command --
# Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

Cypress.Commands.add "el", prevSubject: "optional", (subject, id) =>
  if subject?
    cy.get(subject.selector).find("[data-cy=#{id}]")
  else
    cy.get("[data-cy=#{id}]")

Cypress.Commands.add "elem",  (id) =>
  cy.get("[data-cy=#{id}]")


Cypress.Commands.add "child",prevSubject: "element", (subject, id) =>
  subject.find("[data-cy=#{id}]")


Cypress.Commands.add "tinymce_type", (text) =>
  cy.get(".tinymce-textarea").invoke("attr", "id").then (id) ->
    cy.window().then (win) ->
      win.tinyMCE.get(id).setContent(text)

Cypress.Commands.add "app_login", (user="Joe Admin") =>
  cy.app("login", user)

Cypress.Commands.add "login", (email="joe@admin.com", password="joe_pass") =>
  # cy.setCookie("user_testdeck_test", "11862")
  cy.request
    method: "POST",
    url: "/update/*signin",
    body:
      card:
        subcards:
          "+*email": { content: email }
          "+*password": { content: password }


Cypress.Commands.add "logout", () =>
  cy.request
    method: "DELETE",
    url: "/delete/*signin"
