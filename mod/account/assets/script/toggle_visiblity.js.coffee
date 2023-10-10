$ ->
  passwordField = $("#card_subcards___password_content")
  togglePassword = $("#toggle-password")

  togglePassword.on "click", () ->
    if passwordField.prop("type") is "password"
      passwordField.prop("type", "text")
      togglePassword.find("i").text("visibility")
    else
      passwordField.prop("type", "password")
      togglePassword.find("i").text("visibility_off")
