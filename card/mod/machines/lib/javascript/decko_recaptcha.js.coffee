jQuery.fn.extend {
  reloadCaptcha: ->
    this[0].empty()
    grecaptcha.render this[0],
      sitekey: decko.recaptchaKey
}

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