$ ->
  $("body").on "click", "._toggle-password", (event) ->
    passwordField = $("input._toggle-password")
    togglePassword = $("span._toggle-password")

    if passwordField.prop("type") is "password"
      passwordField.prop("type", "text")
      togglePassword.find("i").text("visibility")
    else
      passwordField.prop("type", "password")
      togglePassword.find("i").text("visibility_off")

