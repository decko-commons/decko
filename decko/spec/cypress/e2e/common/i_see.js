import { Then } from "cypress-cucumber-preprocessor/steps";

Then(`I see {string}`, (title) => {
  cy.contains(title)
})
