describe 'layouts', () ->
  before ->
    cy.login()

  specify "visit card with simple layout", ->
    cy.ensure "simple layout",
              content: "Simple Header {{_main}} Simple Footer",
              type: "layout"
    cy.ensure "*account links+*self+*layout",
              content: "[[simple layout]]",
              type: "pointer"

    cy.visit "/*account_links"
    cy.contains "Simple Header"
    cy.contains "Joe Admin"
    cy.delete "*account links+*self+*layout"

  specify "visit User card with user layout", () ->
    cy.ensure "user layout",
              content: "User Header {{_main}} Simple Footer",
              type: "layout"

    cy.ensure "User+*type+*layout", content: "[[user layout]]", type: "pointer"
    cy.visit "/Joe_User"
    cy.contains "User Header"
    cy.delete "User+*type+*layout"
