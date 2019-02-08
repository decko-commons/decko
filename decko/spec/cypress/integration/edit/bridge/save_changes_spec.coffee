describe 'save change in bridge', () ->
  before ->
    #cy.app_login()
    cy.login()
    cy.app("scenarios/save_changes")
    # cy.clear_machine_cache()

  specify "'save and close' updates main slot", () ->
    cy.visit_bridge("snow")

    cy.tinymce_type "white"
    cy.el("submit-modal").click()
    cy.expect_main_content "white"
    cy.bridge().should "not.be.visible"

  specify "'save' updates main slot", () ->
      cy.visit_bridge("snow")

      cy.tinymce_type("black").then ->
        cy.el("save").click(force: true)
        cy.expect_main_content "black"
        cy.bridge().should "be.visible"

  specify "'save and close' updates non-main origin slot", () ->
    cy.visit("/")

    cy.slot("menu").find(".card-menu > a").click(force: true)
    cy.tinymce_type("fruit pants")
    cy.el("submit-modal").click()
    cy.slot("menu").should("contain", "fruit pants")
    cy.slot("home").should("not.contain", "fruit pants")

  specify "'save' updates non-main origin slot", () ->
    cy.visit("/")

    cy.slot("menu").find(".card-menu > a").click(force: true)
    cy.tinymce_type("function snug").then ->
      cy.el("save").click()
      cy.el("close-modal").click().then ->
        cy.slot("menu").should("contain", "function snug")
        cy.slot("home").should("not.contain", "function snug")

  it "updates origin slot after name change", () ->
    cy.visit_bridge("snow")
    cy.slot("snow", "edit_name_row").el("edit-link").click(force: true)
    cy.get(".name-editor > input[name='card[name]']").clear().type("rain")
    cy.get("button.renamer").click().click()
    cy.el("close-modal").click()

    cy.expect_main_title("rain")

  it "updates origin slot after type change", () ->
    cy.visit_bridge("ice")
    cy.slot("ice", "edit_type_row").el("edit-link").click(force: true)
    cy.select2_by_name("card[type]", "Book")
    cy.el("close-modal").click()

    cy.bridge().should "contain", "ice+author"

