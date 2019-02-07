describe 'table of contents', () ->
  before ->
    cy.app("scenarios/bridge/rules/table_of_contents")
    cy.login()


  beforeEach ->
    cy.visit_bridge()

  specify 'always on setting', () ->
    cy.bridge_sidebar().find('.nav-tabs a:last').click()
    #cy.wait(1000)
    cy.bridge_sidebar().find("[data-cy=structure-pill]").click()
    cy.tinymce_type "new structure"

    cy.el("submit-overlay").should("have.class", "_rule-submit-button").click()
    cy.get(".card-notice").should("contain", "To what Set does this Rule apply?")

  it 'warns if set "all" was selected', (done) ->
    cy.bridge_sidebar().get('.nav-tabs a:last').click()
    cy.bridge_sidebar().find("[data-cy=default-pill]").click()
    cy.get("#card_name_alldefault").check()

    cy.on "window:confirm", (str) ->
      expect(str).to.contain "This rule will affect all cards"
      done()

    cy.el("submit-overlay").click()
