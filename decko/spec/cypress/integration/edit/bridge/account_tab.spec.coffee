describe 'account tab', () ->
  before ->
    cy.login("sample@user.com", "sample_pass")

  beforeEach ->
    cy.visit_bridge("Sample User")

  after ->
    cy.logout()

  specify 'change email', () ->
    labeled_view = ".SELF-sample_user-Xaccount-Xemail.labeled-view"
    cy.bridge_sidebar().get('.nav-tabs a:first').click()
    cy.el("detail-pill").click()
    cy.get("#{labeled_view} a.edit-link").click force: true
    cy.get(".RIGHT-Xemail input.d0-card-content").clear().type("sam@user.com{enter}")
    cy.get(labeled_view).should("contain", "sam@user.com")

    # cancel
    cy.get("#{labeled_view} a.edit-link").click force: true
    cy.get(".RIGHT-Xemail input.d0-card-content").clear()
    cy.get(".cancel-button").click()
    cy.get(labeled_view).should("contain", "sam@user.com")

    # cy.get("input.d0-card-content").clear().type("sample@user.com{enter}")

