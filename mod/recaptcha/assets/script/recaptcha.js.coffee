$(window).ready ->
  $('body').on 'submit', 'form.slotter', (event)->
    handleRecaptcha event if $(this).data('recaptcha') == 'on'

handleRecaptcha = (event) ->
  recaptcha = $(this).find("input._recaptcha-token")

  if !recaptcha[0]?
    # monkey error (bad form)
    recaptcha.val "recaptcha-token-field-missing"
  else if recaptcha.hasClass "_token-updated"
    # recaptcha token is fine - continue submitting
    recaptcha.removeClass "_token-updated"
  else if !grecaptcha?
    # shark error (probably recaptcha keys of pre v3 version)
    recaptcha.val "grecaptcha-undefined"
  else
    updateRecaptchaToken(event)
    # this stops the submit here
    # and submits again when the token is ready

updateRecaptchaToken = (event) ->
  recaptcha = $(this).find("input._recaptcha-token")

  if !recaptcha[0]?
    recaptcha.val "recaptcha-token-field-missing"
  else if !grecaptcha?
    recaptcha.val "grecaptcha-undefined"
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
