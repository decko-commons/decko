describe 'reference', () ->
  before ->
    cy.login()
    # cy.clear_machine_cache()

  specify "simple cardtype autoname", ->
    cy.ensure "Vignesh", type: "PlainText", content: "Indian"
    cy.ensure "Kawaii Man", type: "PlainText", content: "[[Vignesh]]"
    cy.delete "Srivigneshwar"
    cy.visit "/Vignesh?view=edit_name"
    cy.get("#card_name").clear().type "Srivigneshwar"
    cy.get("button.renamer").click()
    cy.contains("Rename and Update").click()
    cy.visit("Kawaii Man")
    cy.main_slot().should "contain", "Srivigneshwar"

