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
    cy.wrap(subject).find("[data-cy=#{id}]")
  else
    cy.get("[data-cy=#{id}]")

Cypress.Commands.add "elem",  (id) =>
  cy.get("[data-cy=#{id}]")

Cypress.Commands.add "child",prevSubject: "element", (subject, id) =>
  subject.find("[data-cy=#{id}]")

Cypress.Commands.add "tinymce_set_content", (text) =>
  cy.tinymce (ed) ->
    ed.setContent(text)

Cypress.Commands.add "tinymce", (fun) =>
  cy.get("iframe.tox-edit-area__iframe").then -> # wait for tinymce
    cy.wait(1000)
    cy.get(".tinymce-textarea").invoke("attr", "id").then (id) ->
      cy.window().then (win) ->
        fun(win.tinymce.get(id), win)

Cypress.Commands.add "tinymce_type", (text) =>
  cy.tinymce (ed, win) ->
    ed.focus()
    t = text.replace("{cursor}", "<span id='mymarker'>\u200b</span>")
    ed.insertContent(t)
    marker = win.jQuery(ed.getBody()).find('#mymarker')
    ed.selection.select(marker.get(0))
    marker.remove()
#
#      e = win.jQuery.Event('keypress')
#      e.keyCode = 37  #Left arrow keycode
#      cy.document().then (doc) ->
#        win.jQuery(doc).trigger(e)
#        win.jQuery(doc).trigger(e)
#        win.jQuery(doc).trigger(e)

Cypress.Commands.add "tinymce_content", () =>
  cy.get("iframe.tox-edit-area__iframe") # wait for tinymce
  cy.get(".tinymce-textarea").invoke("attr", "id").then (id) ->
    cy.window().then (win) ->
      win.tinymce.get(id).getContent()

#Cypress.Commands.add "app_login", (user="Joe Admin") =>
#  cy.app("login", user)

Cypress.Commands.add "login", (email="joe@admin.com", password="joe_pass") =>
  # cy.setCookie("user_testdeck_test", "11862")
  cy.session([email, password], () =>
    cy.request
      method: "POST",
      url: "/update/:signin",
      body:
        card:
          fields:
            ":email": email
            ":password": password)


Cypress.Commands.add "logout", () =>
  cy.request
    method: "DELETE",
    url: "/delete/*signin"
