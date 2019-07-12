describe 'edit content', () ->
  before ->
    cy.login()

  specify "edit content modal", () ->
    cy.ensure "cyp", "original"
    cy.visit("/cyp?view=edit")
    cy.tinymce_set_content("new content")
    cy.el("submit-modal").click()
    cy.contains "new content"

  specify "double click", () ->
    cy.ensure "editmodes", "{{A+B}} {{Z|edit: inline}} {{T|edit: full}}"

    cy.visit "editmodes"
    cy.get(".SELF-a-b.d0-card-content").click().dblclick()
    cy.get("iframe.tox-edit-area__iframe")
    cy.get("#a-b-edit-view").contains("Cancel").click()
    cy.get("#a-b-edit-view").should "not.exist"
    cy.get(".SELF-t.card-slot").click().dblclick()
    cy.get("iframe.tox-edit-area__iframe")
    cy.get(".bridge-main #t-bridge-view").contains("Cancel").click()
    cy.get(".bridge-main").should "not.exist"
    cy.get(".SELF-z.card-slot").dblclick()
    cy.get("iframe.tox-edit-area__iframe")
    cy.get("#z-edit_inline-view").contains("Cancel").click()
    cy.get("#z-edit_inline-view").should "not.exist"
