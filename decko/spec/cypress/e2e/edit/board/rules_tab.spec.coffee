describe 'rules tab', () ->
  before ->
    cy.login()

  beforeEach ->
    cy.visit_board()

  specify 'no set selected', () ->
    cy.board_sidebar().find('.nav-tabs a:last').click()
    cy.board_sidebar().select2_by_name("mark", "The card \"A\"")
    cy.board_sidebar().contains("templating").click()
    cy.board_sidebar().contains("structure").click()

    cy.tinymce_set_content "new structure"

    cy.el("submit-overlay").should("have.class", "_rule-submit-button").click()
    cy.get(".card-notice").should("contain", "To what Set does this Rule apply?")

  it 'warns if set "all" was selected', (done) ->
    cy.board_sidebar().get('.nav-tabs a:last').click()
    cy.board_sidebar().select2_by_name("mark", "The card \"A\"")
    cy.board_sidebar().contains("templating").click()
    cy.board_sidebar().contains("template for new cards").click()

    cy.get("input[value='*all+*default']").check()

    cy.on "window:confirm", (str) ->
      expect(str).to.contain "This rule will affect all cards"
      done()

    cy.el("submit-overlay").click()
