input = (content) ->
  cy.ensure "friends+*right+*input_type", type: "phrase", content: content

describe 'editing pointers', () ->
  before ->
    cy.login()

  beforeEach ->
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
    cy.ensure "User+*type+*structure", "{{+friends}}"
    input "select"
    cy.visit_bridge("Joe User")
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

  specify 'create with filtered list input', () ->
    input "filtered list"

    cy.visit("/Joe User+friends")
    cy.get("._add-item-link").click()
    cy.contains("Select Item")
    cy.contains("button", "More Filters").click()
    cy.contains("a","Name").click()
    cy.get("._filter-container [name='filter[name]']").type("Joe{enter}").then ->
      cy.get("._search-checkbox-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")
      cy.contains(/select\s+3\s+following/)
      cy.get("input._select-all").click()
      # cy.contains(/select\s+0\s+following/)
      cy.get("._add-selected").click().should("not.contain", "input._select-all")
      cy.get("._filtered-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")

      cy.get("._add-item-link").click()
      cy.get("input[name='Big Brother']").click()
      cy.get("._add-selected").click()
      cy.get("._filtered-list")
        .should("contain", "Joe Camel")
        .should("contain", "Big Brother")
        .should("not.contain", "u1")

# filtered list doesn't work with pointer options (instead of search options)
#  specify 'change with filtered list input', () ->
#    cy.visit_bridge("joes")
#    cy.get("._add-item-link").click()
#    cy.get(".checkbox-side").first().click()
#    cy.get("._add-selected").click()
#    cy.get("._filtered-list")
#      .should("contain", "Joe Admin")



