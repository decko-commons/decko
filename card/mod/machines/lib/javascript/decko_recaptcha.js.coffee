jQuery.fn.extend {
  updateRecaptchaToken: (submit) ->
    recaptcha = @find("input._recaptcha-token")
    return unless recaptcha[0]?
    $slotter = $(this)

    grecaptcha.execute(recaptcha.data("site-key"), action: recaptcha.data("action"))
      .then (token) ->
        recaptcha.val(token)
        recaptcha.addClass("_token-updated")
        if submit
          $slotter.submit()
}
