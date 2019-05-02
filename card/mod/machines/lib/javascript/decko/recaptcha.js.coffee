jQuery.fn.extend {
  updateRecaptchaToken: (event) ->
    recaptcha = @find("input._recaptcha-token")

    if !recaptcha[0]?
      recaptcha.val "recaptcha-token-field-missing"
    else if !grecaptcha?
      recaptcha.val("grecaptcha-undefined")
    else
      $slotter = $(this)
      event.stopPropagation() if event
      grecaptcha.execute(recaptcha.data("site-key"), action: recaptcha.data("action"))
        .then (token) ->
          recaptcha.val(token)
          recaptcha.addClass("_token-updated")
          if event
            $slotter.submit()
      false
  }
