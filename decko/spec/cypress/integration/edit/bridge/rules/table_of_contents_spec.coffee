describe 'table of contents', () ->
  before ->
    cy.app "scenarios/bridge/rules/table_of_contents"

  specify 'always on setting', () ->
    cy.app "card/ensure", name: "Basic+*type+*table of contents", content: "1"
    cy.visit("Onne Heading").expect_main_content("Table of Contents")

  specify 'minimum setting', () ->
    cy.app "card/ensure", name: "Basic+*type+*table of contents", content: "2"
    cy.visit("Onne Heading")
    cy.main_slot().should("not.contain", "Table of Contents")
    cy.visit("Three Heading")
    cy.main_slot().should("contain", "Table of Contents")

  specify.only 'always off setting', () ->
    cy.app "card/ensure", name: "Basic+*type+*table of contents", content: "0"
    cy.visit("Onne Heading")
    cy.main_slot().should("not.contain", "Table of Contents")

