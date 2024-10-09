// toggle_visibility.js.coffee
(function() {
  $(function() {
    return $("body").on("click", "._toggle-pw-visibility", function(event) {
      var passwordField, togglePassword;
      passwordField = $("._pw-input");
      togglePassword = $("._pw-text-area");
      if (passwordField.prop("type") === "password") {
        passwordField.prop("type", "text");
        return togglePassword.find("i").text("visibility");
      } else {
        passwordField.prop("type", "password");
        return togglePassword.find("i").text("visibility_off");
      }
    });
  });

}).call(this);
