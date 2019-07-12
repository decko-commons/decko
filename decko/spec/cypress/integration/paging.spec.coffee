describe 'paging', () ->
  before ->
    cy.login()
    cy.ensure "basic card search", content: '{"type":"RichText"}', type: "search"

  it "keeps item structure when jumping to pages", ->
    cy.ensure "basic item structure", "{{_|name}}"
    cy.ensure "list all basic cards", "{{basic card search||content;structure:basic item structure}}"
    cy.visit "/list_all_basic_cards"
    cy.contains(".page-item", "2").click()
    cy.contains(".page-item.active", "2")
    cy.contains(".search-result-item .STRUCTURE-basic_item_structure", "Narcissist+*account")
    cy.contains(".page-item", "3").click()
    cy.contains(".page-item.active", "3")
    cy.get(".search-result-item .STRUCTURE-basic_item_structure")

  it "keeps the item view", () ->
    cy.ensure "list basic types", "{{basic card search|open|closed}}"
    cy.visit "/list_basic_types"
    cy.contains(".page-item", "2").click()
    cy.contains(".page-item.active", "2")
    cy.contains(".search-result-item .closed-view ", "Narcissist+*account")
    cy.contains(".page-item", "3").click()
    cy.contains(".page-item.active", "3")
    cy.get(".TYPE-search.open-view .search-result-item .closed-view")
