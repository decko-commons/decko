 describe 'history tab', () ->
  before ->
    cy.login()
    cy.ensure "no history", type: 'basic'
    cy.ensure "no history", content: "add history"

  beforeEach ->
    cy.visit_bridge('no history')
    cy.bridge_sidebar().find('.nav-tabs a').eq(2).click()

  specify 'changes appear in the pills list', () ->
    count = cy.get("ul.bridge-pills li").its('length')
    # if the history has only one entry then it's preseleced and we have to close it
    # We avoid that by adding a second entry in the before step
    # cy.get('a[data-bs-dismiss="overlay"]').click()
    cy.tinymce_set_content("new content")
    cy.el("save").click()
    # the following fails if the test run more often than entries fit on one page
    # cy.get("ul.bridge-pills li").its('length').should("have.length", count + 1)
    # cy.contains("##{count + 1} Joe Admin")
    cy.contains("Joe Admin less than a minute ago")
    cy.delete 'no history'