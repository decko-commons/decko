# find card slot by card name (and view)
Cypress.Commands.add "slot", (cardname, view) =>
  safe_name = cardname.replace(/\+/g, "-").replace(/\*/g, "X")
  selector = ".card-slot.SELF-#{safe_name}"
  selector += ".#{view}-view" if view?
  cy.get(selector)

Cypress.Commands.add "main_slot", () =>
  cy.get("#main > .card-slot")

# click the edit icon
Cypress.Commands.add "click_edit", { prevSubject: 'element'}, (subject) =>
  cy.wrap(subject).find(".card-menu > a.edit-link").click(force: true)

Cypress.Commands.add "bar", (cardname) =>
  cy.get(".bar-view").find ".bar[data-card-name='#{cardname}']"

Cypress.Commands.add "expect_main_title", (text) =>
  cy.get("#main > .card-slot > .d0-card-header > .d0-card-header-title .card-title")
    .should("contain", text)

Cypress.Commands.add "expect_main_content", (text) =>
  cy.get("#main > .card-slot > .d0-card-body")
    .should("contain", text)

Cypress.Commands.add "rename", (old_name, new_name) =>
  cy.request
    method: "POST",
    url: "/update/#{old_name}?card[name]=#{new_name}"

Cypress.Commands.add "retype", (name, new_type) =>
  cy.request
    method: "POST",
    url: "/update/#{name}?card[type]=#{new_type}"

Cypress.Commands.add "clear_script_cache", () =>
  cy.request
    method: "POST",
    url: "/update/*admin?task=clear_script_cache"

Cypress.Commands.add "clear_machine_cache", () =>
  cy.request
    method: "POST",
    url: "/update/*admin?task=clear_machine_cache"

Cypress.Commands.add "field", (name) =>
  cy.get "[name='card[subcards][+#{name}][content]']"

# 'name' is name attribute of the select tag
Cypress.Commands.add "select2_by_name", prevSubject: "optional", (subject, name, value) =>
  selector = "select[name='#{name}'] + .select2-container"
  if subject
    cy.wrap(subject).find(selector).click()
  else
    cy.get(selector).click()

  cy.root().get("span.select2-results").contains(value).click()

Cypress.Commands.add "select2", { prevSubject: "element" }, (subject, value) =>
  # cy.wrap(subject)
  #tag = cy.wrap(subject).invoke("attr", "'data-select2-id'")
  #cy.log "tagname"
  #cy.log tag
  #if cy.wrap(subject).invoke("prop", "tagName") == "SELECT"
  cy.wrap(subject).siblings(".select2-container").click()
  #else
  #  cy.wrap(subject).find(".select2-container").click()

  cy.root().get("span.select2-results").contains(value).click()

Cypress.Commands.add "searchAndSelect2", { prevSubject: "element" }, (subject, type, value) =>
  cy.wrap(subject).siblings(".select2-container").click()
  cy.wait(500) # wait for the input field to be ready
  cy.root().get(".select2-dropdown > .select2-search > .select2-search__field").type(type)
  cy.root().get("span.select2-results").contains(value).click()

Cypress.Commands.add "unfollow", (card, user="Joe_Admin") =>
  cy.request
    method: "POST",
    url: "/update/#{card}+*self+#{user}+*follow?card%5Bcontent%5D=%5B%5B%2Anever%5D%5D"

Cypress.Commands.add "follow", (card, user="Joe_Admin") =>
  cy.request
    method: "POST",
    url: "/update/#{card}+*self+#{user}+*follow?card%5Bcontent%5D=%5B%5B%2Aalways%5D%5D"

Cypress.Commands.add "ensure", (name, args={}) =>
  cy.app "cards/ensure", name: name, args: args

Cypress.Commands.add "delete", (name) =>
  cy.app "cards/delete", name

Cypress.Commands.add "update", (name, content) =>
  cy.app "cards/update", name: name, content: content

Cypress.Commands.add "editor", (field) =>
  cy.get ".card-editor.RIGHT-#{field} .content-editor"

#Cypress.Commands.add "closeFilter", (field) =>
#  cy.get(".close-filter-#{field}").click()
