describe 'paging', () ->
  before ->
    cy.login()
    cy.ensure "basic card search",
              type: "search",
              content: '{"type":"RichText","sort":"name", "not": { "right": {} }}'

  it "keeps item structure when jumping to pages", ->
    cy.ensure "basic item structure", content: "{{_|name}}"
    cy.ensure "list all basic cards",
              content: "{{basic card search||content;structure:basic item structure}}"
    cy.visit "/list_all_basic_cards"
    cy.contains(".page-item", "2").click()
    cy.contains(".page-item.active", "2")
    cy.contains(".search-result-item .STRUCTURE-basic_item_structure", "*from")
    # *from is a card that shows up on page 2
    cy.contains(".page-item", "3").click()
    cy.contains(".page-item.active", "3")
    cy.get(".search-result-item .STRUCTURE-basic_item_structure")

  it "keeps the item view", () ->
    cy.ensure "list basic types", content: "{{basic card search|open|closed}}"
    cy.visit "/list_basic_types"
    cy.contains(".page-item", "2").click()
    cy.contains(".page-item.active", "2")
    cy.contains(".search-result-item .closed-view ", "*from")
    cy.contains(".page-item", "3").click()
    cy.contains(".page-item.active", "3")
    cy.get(".TYPE-search.open-view .search-result-item .closed-view")
