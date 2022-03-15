# There are three places that can control what happens after an ajax request
#  1. the element that triggered the request (eg. a link or a button)
#  2. the closest ".slotter" element
#      (if the trigger itself isn't a slotter,
#       a common example is that a form is a slotter but the form buttons aren't)
#  3. the slot returned by the request
#
# A slot is an element marked with "card-slot" class, a slotter has a "slotter" class.
# By the default, the closest slot of the slotter is replaced with the new slot that the
# request returned. The behavior can be changed with css classes and data attributes.
#
#  To 1. The trigger element has only a few options to override the slotter.
#    classes:
#    "_close-modal-on-success"
#    "_close-overlay-on-success"
#    "_update-origin"
#
#  To 2. The slotter is the standard way to define what happens with request result
#    data:
#    slot-selector
#        a css selector that defines which slot will be replaced.
#        You can also use "modal-origin" and "overlay-origin" to refer to the origin slots.
#    slot-success-selector/slot-error-selector
#        the same as slot-selector but only used
#        for success case or error case, respectively
#    update-foreign-slot
#        a css selector to specify an additional slot that will be
#        updated after the request.
#    update-foreign-slot-url
#        a url to fetch the new content for the additional slot
#        if not given the slot is updated with the same card and view that was used before
#    update-origin
#        if present then the slot from where the current modal or overlay slot was opened
#        will be updated
#    slotter-mode
#        possible values are
#          replace (default)
#             replace the closest slot with new slot
#          modal
#             show new slot in modal; if there is already a modal then put it on top
#           modal-replace
#             replace existing modal
#          overlay
#             show new slot in overlay
#          update-origin
#             update closest slot of the slotter that opened the modal or overlay
#             (assumes that the request was triggered from a modal or overlay)
#             If you need the update-origin mode together with another mode then use
#             data-update-origin="true".
#          silent-success
#             do nothing
#
#    classes:
#    _close-overlay
#    _close-modal
#
#   To 3. Similar as 1, the slot has only overlay and modal options.
#     classes:
#     _modal
#        show slot in modal
#     _overlay
#        show slot in overlay
#
#
$(window).ready ->
  $('body').on 'ajax:success', '.slotter', (event, data) ->
    $(this).slotterSuccess event, data

  $('body').on 'ajax:error', '.slotter', (event, xhr) ->
    $(this).showErrorResponse xhr.status, xhr.responseText

  $('body').on 'click', 'button.slotter', (event)->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote $(this)

  $('body').on 'click', '._clickable.slotter', (event)->
    $(this)[0].href = $(this).attr("href") # that's where rails.handleRemote
                                           # expects the url
    $.rails.handleRemote $(this)

  $('body').on 'click', '[data-dismiss="overlay"]', (event) ->
    $(this).findSlot(".card-slot._overlay").removeOverlay()

  $('body').on 'click', '._close-overlay-on-success', (event) ->
    $(this).closeOnSuccess("overlay")

  $('body').on 'click', '._close-modal-on-success', (event) ->
    $(this).closeOnSuccess("modal")

  $('body').on 'click', '._close-on-success', (event) ->
    $(this).closeOnSuccess()

  $('body').on 'click', '._update-origin', (event) ->
    $(this).closest('.slotter').data("slotter-mode", "update-origin")

  $('body').on 'submit', 'form.slotter', (event)->
    form = $(this)
    if form.data("main-success") and form.isMainOrMainModal()
      form.mainSuccess()
    if form.data('recaptcha') == 'on'
      return form.handleRecaptchaBeforeSubmit(event)

  $('body').on 'ajax:beforeSend', '.slotter', (event, xhr, opt)->
    $(this).slotterBeforeSend opt

jQuery.fn.extend
  mainSuccess: ()->
    form = $(this)
    $.each form.data("main-success"), (key, value)->
      inputSelector = "[name=success\\[" + key + "\\]]"
      input = form.find inputSelector
      unless input[0]
        input = $('<input type="hidden" name="success[' + key + ']"/>')
        form.append input
      input.val value

  slotterSuccess: (event, responseData) ->
    # debugger
    unless @hasClass("slotter")
      console.log "warning: slotterSuccess called on non-slotter element #{this}"
      return

    return if event.slotSuccessful

    @showSuccessResponse responseData, @data("slotter-mode")

    if @hasClass "_close-overlay"
      @removeOverlay()
    if @hasClass "_close-modal"
      @closest('.modal').modal "hide"

    # should scroll to top after clicking on new page
    if @hasClass "card-paging-link"
      slot_top_pos = @slot().offset().top
      $("body").scrollTop slot_top_pos
    if @data("update-foreign-slot")
      $slot = @findSlot @data("update-foreign-slot")
      reload_url = @data("update-foreign-slot-url")
      $slot.reloadSlot reload_url

    if @data('original-slotter-mode')
      @attr 'data-slotter-mode', @data('original-slotter-mode')
    if @data('original-slot-selector')
      @attr 'data-slot-selector', @data('original-slot-selector')

    event.slotSuccessful = true

  showSuccessResponse: (responseData, mode) ->
    if responseData.redirect
      window.location = responseData.redirect
    else if responseData.reload
      window.location.reload(true)
    else
      switch mode
        when "silent-success" then return
        when "update-modal-origin" then @updateModalOrigin()
        when "update-origin" then @updateOrigin()
        else @updateSlot responseData, mode

  showErrorResponse: (status, result) ->
    if status == 403 #permission denied
      $(result).showAsModal $(this)
    else if status == 900
      $(result).showAsModal $(this)
    else
      @notify result, "error"

      if status == 409 #edit conflict
        @slot().find('.current_revision_id').val(
          @slot().find('.new-current-revision-id').text()
        )

  updateModalOrigin: () ->
    if @overlaySlot()
      overlayOrigin = @findOriginSlot("overlay")
      overlayOrigin.updateOrigin()
    else if @closest("#modal-container")[0]
      @updateOrigin()

  updateOrigin: () ->
    type = if @overlaySlot()
      "overlay"
    else if @closest("#modal-container")[0]
      "modal"

    return unless type?

    origin = @findOriginSlot(type)
    if origin && origin[0]?
      origin.reloadSlot()

  registerAsOrigin: (type, slot) ->
    if slot.hasClass("_modal-slot")
      slot = slot.find(".modal-body")  # put the origin slot id on the modal-body instead
                                        # of on the slot, so that it survives slot reloads
    slot.attr("data-#{type}-origin-slot-id", @closest(".card-slot").data("slot-id"))

  updateSlot: (newContent, mode) ->
    mode ||= "replace"
    @setSlotContent newContent, mode, $(this)

  # close modal or overlay
  closeOnSuccess: (type) ->
    slotter = @closest('.slotter')
    if !type?
      type = if @isInOverlay() then "overlay" else "modal"
    slotter.addClass "_close-#{type}"

  slotterBeforeSend: (opt) ->
    return if opt.skip_before_send

    # avoiding duplication. could be better test?
    unless (opt.url.match(/home_view/) or @data("slotter-mode") == "modal")
      opt.url = decko.slotPath opt.url, @slot()

    if @is('form')
      if data = @data 'file-data'
# NOTE - this entire solution is temporary.
        @uploadWithBlueimp(data, opt)
        false

  uploadWithBlueimp: (data, opt) ->
    input = @find '.file-upload'
    if input[1]
      @notify(
        "Decko does not yet support multiple files in a single form.",
        "error"
      )
      return false

    widget = input.data 'wblueimpFileupload' #jQuery UI widget

    # browsers that can't do ajax uploads use iframe
    unless widget._isXHRUpload(widget.options)
      # can't do normal redirects.
      @find('[name=success]').val('_self')
      # iframe response not passed back;
      # all responses treated as success.  boo
      opt.url += '&simulate_xhr=true'
      # iframe is not xhr request,
      # so would otherwise get full response with layout
      iframeUploadFilter = (data)-> data.find('body').html()
      opt.dataFilter = iframeUploadFilter
    # gets rid of default html and body tags

    args = $.extend opt, (widget._getAJAXSettings data), url: opt.url
    # combines settings from decko's slotter and jQuery UI's upload widget
    args.skip_before_send = true #avoid looping through this method again

    $.ajax( args )

  handleRecaptchaBeforeSubmit: (event) ->
    recaptcha = @find("input._recaptcha-token")

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
      @updateRecaptchaToken(event)
      # this stops the submit here
      # and submits again when the token is ready

