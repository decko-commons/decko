input = (content) ->
  cy.ensure "friends+*right+*input", type: "phrase", content: content

describe 'editing pointers', () ->
  before ->
    cy.login()

  beforeEach ->
    cy.app("cards/delete", "Joe User+friends")

  specify "create with select input", ->
    input "select"
    #cy.wait(1000)
    cy.visit("/Joe User+friends")
    cy.contains(".form-group", "content").find(".select2-container").click()
      .select2("Joe Camel")
    cy.contains("Submit").click()
    cy.main_slot()
      .should("not.contain", "Submitting")
      .should "contain", "Joe Camel"

  specify "create a structured card including select input", ->
    input "select"
    cy.ensure "User+*type+*structure", "{{+friends}}"
    cy.visit_bridge("Joe User")
    cy.contains(".form-group", "+friends").find(".select2-container").click()
    cy.select2("Joe Camel")
    cy.contains("Save and Close").click()
    cy.main_slot()
      .should "contain", "Joe Camel"

#    specify "create with multiselect input", ->
#    input "multiselect"
#    cy.visit("/Joe User+friends")
#    cy.select2("pointer_select-joe_user-friend-1", "Joe Camel")
#    cy.contains("Submit").click()
#    cy.main_slot()
#      .should "contain", "Joe Camel"


  specify 'create with filtered list input', () ->
    input "filtered list"
    cy.visit("/Joe User+friends")
    cy.get("._add-item-link").click()
    cy.contains("Select Item")
    cy.contains("button", "Add filter").click()
    cy.contains("a","Keyword").click()
    cy.get("[name='filter[name]']").type("Joe{enter}").then ->
      cy.get("._search-checkbox-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")
      cy.contains(/select\s+3\s+following/)
      cy.get("input._select-all").click()
      cy.get("._add-selected").click()
      cy.get("._pointer-filtered-list")
        .should("contain", "Joe Admin")
        .should("contain", "Joe User")
        .should("contain", "Joe Camel")

      cy.get("._add-item-link").click()
      cy.get("input[name='Big Brother']").click()
      cy.get("._add-selected").click()
      cy.get("._pointer-filtered-list")
        .should("contain", "Joe Camel")
        .should("contain", "Big Brother")
        .should("not.contain", "u1")

# filtered list doesn't work with pointer options (instead of search options)
#  specify 'change with filtered list input', () ->
#    cy.visit_bridge("joes")
#    cy.get("._add-item-link").click()
#    cy.get(".checkbox-side").first().click()
#    cy.get("._add-selected").click()
#    cy.get("._pointer-filtered-list")
#      .should("contain", "Joe Admin")



