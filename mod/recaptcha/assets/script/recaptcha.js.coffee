$(window).ready ->
  $('body').on 'submit', 'form.slotter', (event)->
    form = $(this)
    handleRecaptcha form, event if form.data('recaptcha') == 'on'

handleRecaptcha = (form, event) ->
  recaptcha = form.find("input._recaptcha-token")

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
    updateRecaptchaToken(form, event)
# this stops the submit here
# and submits again when the token is ready

updateRecaptchaToken = (form, event) ->
  recaptcha = form.find("input._recaptcha-token")

  if !recaptcha[0]?
    recaptcha.val "recaptcha-token-field-missing"
  else if !grecaptcha?
    recaptcha.val "grecaptcha-undefined"
  else
    event.stopPropagation() if event
    executeGrecaptcha recaptcha
    form.submit() if event
    false

executeGrecaptcha = (recaptcha) ->
  siteKey = recaptcha.data "site-key"
  action = recaptcha.data "action"
  grecaptcha.execute(siteKey, action: action).then (token) ->
    recaptcha.val token
    recaptcha.addClass "_token-updated"
