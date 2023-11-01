describe 'account tab', () ->
  before ->
    cy.login("sample@user.com", "sample_pass")

  beforeEach ->
    cy.visit_board("Sample User")

  after ->
    cy.logout()

  specify 'change email', () ->
    labeled_view = ".SELF-sample_user-Xaccount-Xemail.labeled-view"

    cy.board_sidebar().get('.nav-tabs a:first').click()
    cy.el("email_and_password-pill").click()
    cy.get("#{labeled_view} a.edit-link").click force: true
    cy.get(".RIGHT-Xemail input.d0-card-content")
      .clear(force: true).type("sam@user.com", force: true)
    cy.get(".submit-button:visible").click()
    cy.get(labeled_view).should("contain", "sam@user.com")

    # cancel
    cy.wait 250 # let modal close.
    cy.get("#{labeled_view} a.edit-link").click force: true
    cy.get(".RIGHT-Xemail input.d0-card-content:visible").clear()
    cy.get(".cancel-button:visible").click()
    cy.get(labeled_view).should("contain", "sam@user.com")
