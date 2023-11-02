input = (content) ->
  cy.ensure "friends+*right+*input_type", type: "phrase", content: content

describe 'editing pointers', () ->
  beforeEach ->
    cy.login()
    cy.delete "Joe User+friends"

  specify "create with select input", ->
    input "select"
    cy.visit("/Joe User+friends")
    cy.contains(".form-group", "Content").find("select")
      .select2("Joe Camel")
    cy.contains("Submit").click()
    cy.main_slot()
      .should("not.contain", "Submitting")
      .should "contain", "Joe Camel"

  specify "create a structured card including select input", ->
    cy.ensure "User+*type+*structure", content: "{{+friends}}"
    input "select"
    cy.visit_board("Joe User")
    cy.contains(".form-group", "+friends").find("select")
      .select2("Joe Camel")
    cy.contains("Save and Close").click()
    cy.main_slot()
      .should "contain", "Joe Camel"

  specify "create with multiselect input", ->
    input "multiselect"
    cy.visit("/Joe User+friends")
    cy.contains(".form-group", "Content").find("select")
      .select2("Joe Camel")
    cy.contains(".form-group", "Content").find("select")
      .select2("Joe Admin")
    cy.contains("Submit").click()
    cy.main_slot()
      .should "contain", "Joe Camel"
      .should "contain", "Joe Admin"
