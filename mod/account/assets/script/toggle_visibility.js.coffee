$ ->
  $("body").on "click", "._toggle-pw-visibility", (event) ->
    passwordField = $("._pw-input")
    togglePassword = $("._pw-text-area")

    if passwordField.prop("type") is "password"
      passwordField.prop "type", "text"
      togglePassword.find("i").text "visibility"
    else
      passwordField.prop "type", "password"
      togglePassword.find("i").text "visibility_off"
