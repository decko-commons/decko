const { defineConfig } = require('cypress')

// const webpackPreprocessor = require('@cypress/webpack-preprocessor')

module.exports = defineConfig({
  projectId: 'n4h7vq',
  defaultCommandTimeout: 10000,
  watchForFileChanges: false,

  e2e: {
    // We've imported your old cypress plugins here.
    // You may want to clean this up later by importing these.
    setupNodeEvents(on, config) {
      // on('file:preprocessor', webpackPreprocessor())
      return require('./cypress/plugins/index.js')(on, config)
    },
    baseUrl: 'http://localhost:5002',
    specPattern: 'cypress/e2e/**/*.{js,jsx,ts,tsx,coffee,feature}',
    // testIsolation: false
  },
})
