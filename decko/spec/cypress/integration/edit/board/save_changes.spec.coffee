describe 'save change in board', () ->
  before ->
    cy.login()
    cy.appScenario("board/save_changes")

  specify "'save and close' updates main slot", () ->
    cy.visit_board("snow")

    cy.tinymce_set_content "white"
    cy.el("submit-modal").click()
    cy.expect_main_content "white"
    cy.board().should "not.be.visible"

  specify "'save' updates main slot", () ->
      cy.visit_board("snow")

      cy.tinymce_set_content("black").then ->
        cy.el("save").click(force: true)
        cy.expect_main_content "black"
        #cy.board().should "be.visible"

#  specify "'save and close' updates non-main origin slot", () ->
#    cy.visit("/")
#
#    cy.slot("menu").find(".card-menu > a").click(force: true)
#    cy.tinymce_set_content("fruit pants")
#    cy.el("submit-modal").click()
#    cy.slot("menu").should("contain", "fruit pants")
#    cy.slot("home").should("not.contain", "fruit pants")

  it "updates origin slot after name change", () ->
    cy.visit_board("snow")
    cy.slot("snow", "edit_name_row").el("edit-link").click(force: true)
    cy.get(".name-editor > input[name='card[name]']").clear().type("rain")
    cy.get("button.renamer").click()
    cy.board().contains("Renaming").should("not.exist", wait: 20000)
    # cy.el("close-modal").click()

    cy.expect_main_title("rain")
