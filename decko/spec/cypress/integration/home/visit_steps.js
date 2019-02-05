import { Given } from "cypress-cucumber-preprocessor/steps";

const url = '/'
Given('I open homepage', () => {
  cy.visit(url)
})
