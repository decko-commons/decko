// recaptcha.js.coffee
(function() {
  var executeGrecaptcha, handleRecaptcha, updateRecaptchaToken;

  $(window).ready(function() {
    return $('body').on('submit', 'form.slotter', function(event) {
      var form;
      form = $(this);
      if (form.data('recaptcha') === 'on') {
        return handleRecaptcha(form, event);
      }
    });
  });

  handleRecaptcha = function(form, event) {
    var recaptcha;
    recaptcha = form.find("input._recaptcha-token");
    if (recaptcha[0] == null) {
      return recaptcha.val("recaptcha-token-field-missing");
    } else if (recaptcha.hasClass("_token-updated")) {
      return recaptcha.removeClass("_token-updated");
    } else if (typeof grecaptcha === "undefined" || grecaptcha === null) {
      return recaptcha.val("grecaptcha-undefined");
    } else {
      return updateRecaptchaToken(form, event);
    }
  };

  updateRecaptchaToken = function(form, event) {
    var recaptcha;
    recaptcha = form.find("input._recaptcha-token");
    if (recaptcha[0] == null) {
      return recaptcha.val("recaptcha-token-field-missing");
    } else if (typeof grecaptcha === "undefined" || grecaptcha === null) {
      return recaptcha.val("grecaptcha-undefined");
    } else {
      if (event) {
        event.stopPropagation();
      }
      executeGrecaptcha(form, event, recaptcha);
      return false;
    }
  };

  executeGrecaptcha = function(form, event, recaptcha) {
    var action, siteKey;
    siteKey = recaptcha.data("site-key");
    action = recaptcha.data("action");
    return grecaptcha.execute(siteKey, {
      action: action
    }).then(function(token) {
      recaptcha.val(token);
      recaptcha.addClass("_token-updated");
      if (event) {
        return form.submit();
      }
    });
  };

}).call(this);
