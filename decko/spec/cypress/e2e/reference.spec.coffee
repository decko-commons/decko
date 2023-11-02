describe 'reference', () ->
  beforeEach ->
    cy.login()
    # cy.clear_machine_cache()

  specify "simple cardtype autoname", ->
    cy.ensure "Vignesh", type: "PlainText", content: "Indian"
    cy.ensure "Kawaii Man", type: "PlainText", content: "[[Vignesh]]"
    cy.delete "Srivigneshwar"
    cy.visit "/Vignesh?view=edit_name"
    cy.get("#card_name").clear().type "Srivigneshwar", delay: 0
    cy.get("button.renamer").click()
    cy.on "window:confirm", (str) ->
      expect(str).to.equal "Are you sure you want to rename?"
      true
    cy.contains("Renaming").should("not.exist", wait: 20000)
    cy.main_slot().should "contain", "Srivigneshwar"
