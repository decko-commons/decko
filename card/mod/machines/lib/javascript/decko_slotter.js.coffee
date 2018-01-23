$(window).ready ->
  $('body').on 'ajax:success', '.slotter', (event, data, c, d) ->
    unless event.slotSuccessful
      $this = $(this)
      $this.slotSuccess data, $this.hasClass("_slotter-overlay")
      if $this.hasClass "close-modal"
        $this.closest('.modal').modal('hide')
      # should scroll to top after clicking on new page
      if $this.hasClass "card-paging-link"
        slot_top_pos = $this.slot().offset().top
        $("body").scrollTop slot_top_pos
      if $this.data("update-foreign-slot")
        $slot = $this.find_slot $this.data("update-foreign-slot")
        $slot.updateSlot $this.data("update-foreign-slot-url")

      event.slotSuccessful = true

  $('body').on 'ajax:error', '.slotter', (event, xhr) ->
    $(this).slotError xhr.status, xhr.responseText

  $('body').on 'click', 'button.slotter', (event)->
    return false if !$.rails.allowAction $(this)
    $.rails.handleRemote $(this)

  $('body').on 'click', '._clickable.slotter', (event)->
    $.rails.handleRemote $(this)

  $('body').on 'ajax:beforeSend', '.slotter', (event, xhr, opt)->
    return if opt.skip_before_send

    # avoiding duplication. could be better test?
    unless opt.url.match /home_view/
      opt.url = decko.prepUrl opt.url, $(this).slot()

    if $(this).is('form')
      if decko.recaptchaKey and $(this).attr('recaptcha')=='on' and
          !($(this).find('.g-recaptcha')[0])
# if there is already a recaptcha on the page then we don't have to
# load the recaptcha script
        if $('.g-recaptcha')[0]
          addCaptcha(this)
        else
          initCaptcha(this)
        return false

      if data = $(this).data 'file-data'
# NOTE - this entire solution is temporary.
        input = $(this).find '.file-upload'
        if input[1]
          $(this).notify(
            "Decko does not yet support multiple files in a single form.",
            "error"
          )
          return false

        widget = input.data 'blueimpFileupload' #jQuery UI widget

        # browsers that can't do ajax uploads use iframe
        unless widget._isXHRUpload(widget.options)
# can't do normal redirects.
          $(this).find('[name=success]').val('_self')
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
        false

  $('body').on 'submit', 'form.slotter', (event)->
    if (target = $(this).attr 'main-success') and $(this).isMain()
      input = $(this).find '[name=success]'
      if input and !(input.val().match /^REDIRECT/)
        input.val(
          (if target == 'REDIRECT' then target + ': ' + input.val() else target)
        )