describe 'engage tab', () ->
  before ->
    cy.login()
    cy.unfollow("A")
    # cy.clear_machine_cache()

  beforeEach ->
    cy.login()
    cy.visit_board()
    cy.board_sidebar().find('.nav-tabs a').eq(1).click()

  specify 'follow button', () ->
    cy.contains("follow")
      .get('.follow-link').click()
    cy.contains("following")
    cy.contains("1 follower")
    cy.get(".follow-link").click()
    cy.contains("follow")
    cy.contains("0 follower")

  specify "advanced button", () ->
    cy.get("[data-cy=follow-advanced]").click()
    cy.board().get(".title").should("contain", "follow")
    cy.get(".pointer-radio-list input").first().check()
    cy.get("input[value='A+*self+Joe Admin+*follow']").check()
    cy.get("[data-cy=submit-overlay]").click().should("not.exist")

    cy.board_sidebar()
      .should("contain", "1 follower")
      .and("contain", "following")
    # .get('.follow-link').click()
    #    cy.unfollow("A")

  specify "all followed cards", () ->
    cy.el("follow-overview").click()
    cy.board()
      .should("contain", "Follow")
      .and("contain", "Ignore")

  specify "followers", () ->
    cy.follow("A")
    cy.contains("following")
    cy.el("followers").click()
    cy.board()
      .should("contain", "followers")
      .and("contain", "Joe Admin")
    cy.get(".follow-link").click()
    cy.board()
      .should("contain", "followers")
      .and("not.contain", "Joe Admin")

  specify "discussion", () ->
    cy.get('#card_comment').type("yeah")
    cy.get(".comment-buttons > [type=submit]").click()
    cy.board_sidebar()
      .get(".RIGHT-discussion")
      .should("contain", "yeah")
      .and("contain", "Joe Admin")

