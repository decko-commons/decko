describe 'table of contents', () ->
  before ->
    cy.appScenario "bridge/rules/table_of_contents"

  specify 'always on setting', () ->
    cy.ensure "RichText+*type+*table of contents", "1"
    cy.visit("Onne Heading").expect_main_content("Table of Contents")

  specify 'minimum setting', () ->
    cy.ensure "RichText+*type+*table of contents", "2"
    cy.visit("Onne Heading")
    cy.main_slot().should("not.contain", "Table of Contents")
    cy.visit("Three Heading")
    cy.main_slot().should("contain", "Table of Contents")

  specify 'always off setting', () ->
    cy.ensure "RichText+*type+*table of contents", "0"
    cy.visit("Onne Heading")
    cy.main_slot().should("not.contain", "Table of Contents")

