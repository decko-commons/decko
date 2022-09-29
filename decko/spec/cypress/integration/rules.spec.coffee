describe 'rules', () ->
  before ->
    cy.login()

  specify "default setting and plus card override", ->
    cy.app "cards/ensure", name: "*all+*help", content: "say something spicy"
    cy.app "cards/ensure", name: "color+*right+*help", content: "colorblind"
    cy.visit "/Test"
    cy.main_slot().should "contain", "spicy"
    cy.visit "/Test+color"
    cy.main_slot().should "contain", "colorblind"

  specify '*right Set', () ->
    cy.app("cards/ensure",
           name: "cereal+*right+*help",
           content: "I go poopoo for poco puffs").then ->
      cy.wait(500)
      cy.visit("/Test+cereal")
      cy.main_slot()
        .should("not.contain", "something spicy")
        .should("contain", "poopoo")

  specify '*type_plus_right Set', () ->
    cy.app("cards/ensure",
           name: "User+cereal+*type plus right+*help",
           content: "your favorite")
    cy.visit "Joe User+cereal"
    cy.main_slot().should "contain", "your favorite"

    cy.app "cards/ensure",
           name: "User+*type+*structure",
           content: "{{+cereal}}"

    cy.wait(500)
    cy.visit_bridge("Joe User")
    cy.bridge().should "contain", "your favorite"

    cy.visit("Joe Admin+cereal")
    cy.main_slot()
      .should "contain", "your favorite"

  specify "Self Set", () ->
    cy.app "cards/ensure", name: "cereal+*self+*structure", content: "[[cereal structure]]"
    cy.app "cards/ensure", name: "cereal structure", content: "My very own header"
    cy.visit "cereal"
    cy.main_slot().should "contain", "cereal structure"
