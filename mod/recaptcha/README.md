<!--
# @title README - mod: recaptcha
-->
# Recaptcha mod

Captchas are anti-spam tools for differentiating between bots and humans. 
Recaptcha is a specific captcha implementation owned by Google.

| codename           | default name        | purpose                       |
|:-------------------|:--------------------|:------------------------------|
| captcha            | *captcha            | setting for captcha rules     |
| recaptcha_settings | *recaptcha_settings | recaptcha configuration cards |
| site_key           | site key            | recaptcha config field        |
| secret_key         | secret  key         | recaptcha config field        |

## Default card rules

Recaptcha can be turned on or off for sets of cards using `:recaptcha` rules.

| Set          | Setting    | value  |
|:-------------|:-----------|:-------|
| All          | :recaptcha | true   |
| SignUp cards | :recaptcha | true   |

By default, recaptcha is on for all cards and will appear whenever an unsigned-in user 
creates or edits any card. A second rule is included for SignUp cards so that signups
will still use captchas even if the `all` rule is changed.
