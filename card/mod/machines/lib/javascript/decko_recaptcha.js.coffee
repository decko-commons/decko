jQuery.fn.extend {
  reloadCaptcha: ->
    this[0].empty()
    grecaptcha.render this[0],
      sitekey: decko.recaptchaKey
}

loadCaptcha = (form)->
  if $('.g-recaptcha')[0]
    # if there is already a recaptcha on the page then we don't have to
    # load the recaptcha script
    addCaptcha(this)
  else
    initCaptcha(this)

initCaptcha = (form)->
  recapDiv = $("<div class='g-recaptcha' data-sitekey='#{decko.recaptchaKey}'>" +
    "</div>")
  $(form).children().last().after recapDiv
  recapUri = "https://www.google.com/recaptcha/api.js"

  # renders the first element with "g-recaptcha" class when loaded
  $.getScript recapUri

# call this if the recaptcha script is already initialized (via initCaptcha)
addCaptcha = (form)->
  recapDiv = $('<div class="g-recaptcha"></div>')
  $(form).children().last().after recapDiv
  grecaptcha.render recapDiv,
    sitekey: decko.recaptchaKey
