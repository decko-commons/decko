$.extend decko,
  # returns absolute path (starting with a slash)
  # if rawPath is complete url, this returns the complete url
  # if rawPath is relative (no slash), this adds relative root
  path: (rawPath) ->
    if rawPath.match /^\/|:\/\//
      rawPath
    else
      decko.rootPath + '/' + rawPath

  initializeEditors: (range, map) ->
    map = decko.editorInitFunctionMap unless map?
    $.each map, (selector, fn) ->
      $.each range.find(selector), ->
        fn.call $(this)

  pingName: (name, success)->
    $.getJSON decko.path(''), format: 'json', view: 'status', 'card[name]': name, success

  isTouchDevice: ->
    if 'ontouchstart' of window or window.DocumentTouch and
       document instanceof DocumentTouch
      return true
    else
      return detectMobileBrowser()

  # source for this method: detectmobilebrowsers.com
  detectMobileBrowser = (userAgent) ->
    userAgent = navigator.userAgent or navigator.vendor or window.opera
    /(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(userAgent) or /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(userAgent.substr(0, 4))

jQuery.fn.extend {
  notify: (message, status) ->
    slot = @slot(status)
    notice = slot.find '.card-notice'
    unless notice[0]
      notice = $('<div class="card-notice"></div>')
      form = slot.find('.card-form')
      if form[0]
        $(form[0]).append notice
      else
        slot.append notice
    notice.html message
    notice.show 'blind'

  report: (message) ->
    report = @slot().find '.card-report'
    return false unless report[0]
    report.hide()
    report.html message
    report.show 'drop', 750
    setTimeout (->report.hide 'drop', 750), 3000

  autosave: ->
    slot = @slot()
    return if @attr 'no-autosave'
    multi = @closest '.form-group'
    if multi[0]
      return unless id = multi.data 'cardId'
      reportee = ': ' + multi.data 'cardName'
    else
      id = slot.data 'cardId'
      reportee = ''

    # might be better to put this href base in the html
    submit_url = decko.path 'update/~' + id
    form_data = $('#edit_card_'+id).serializeArray().reduce( ((obj, item) ->
      obj[item.name] = item.value
      return obj
    ), { 'draft' : 'true', 'success[view]' : 'blank'});
    $.ajax submit_url, {
      data : form_data,
      type : 'POST'
    }
    ##{ 'card[content]' : @val() },
}

#~~~~~ ( EVENTS )

setInterval (-> $('.card-form').setContentFieldsFromMap()), 20000

$(window).ready ->
  $.ajaxSetup cache: false

  setTimeout (-> decko.initializeEditors $('body')), 10
  # dislike the timeout, but without this forms with multiple TinyMCE editors
  # were failing to load properly

  $('body').on 'loaded.bs.modal', null, (event) ->
    unless event.slotSuccessful
      decko.initializeEditors $(event.target)
      $(event.target).find(".card-slot").trigger("slotReady")
      event.slotSuccessful = true

  $('body').on 'submit', '.card-form', ->
    $(this).setContentFieldsFromMap()
    $(this).find('.d0-card-content').attr('no-autosave','true')
    true

  $('body').on 'click', '.submitter', ->
    $(this).closest('form').submit()

  $('body').on 'click', '.renamer-updater', ->
    $(this).closest('form').find('#card_update_referers').val 'true'

  $('body').on 'submit', '.edit_name-view .card-form', ->
    confirmer = $(this).find '.alert'
    if confirmer.is ':hidden'
      if $(this).find('#referers').val() > 0
        $(this).find('.renamer-updater').show()

      confirmer.show 'blind'
      false

  $('body').on 'click', '.follow-updater', ->
    $(this).closest('form').find('#card_update_all_users').val 'true'

  $('body').on 'submit', '.edit-view.SELF-Xfollow_default .card-form', ->
    confirmer = $(this).find '.confirm_update_all-view'
    if confirmer.is ':hidden'
      $(this).find('.follow-updater').show()

      confirmer.show 'blind'
      false

  $('body').on 'click', 'button.redirecter', ->
    window.location = $(this).attr('href')

  $('body').on 'change', '.live-type-field', ->
    $(this).data 'params', $(this).closest('form').serialize()
    $(this).data 'url', $(this).attr 'href'

  $('body').on 'change', '.edit-type-field', ->
    $(this).closest('form').submit()

  $('body').on 'change', '.autosave .d0-card-content', ->
    content_field = $(this)
    setTimeout ( -> content_field.autosave() ), 500

  $('body').on 'mouseenter', '[hover_content]', ->
    $(this).attr 'hover_restore', $(this).html()
    $(this).html $(this).attr( 'hover_content' )
  $('body').on 'mouseleave', '[hover_content]', ->
    $(this).html $(this).attr( 'hover_restore' )

  $('body').on 'keyup', '.name-editor input', ->
    box =  $(this)
    name = box.val()
    decko.pingName name, (data)->
      return null if box.val() != name # avert race conditions
      status = data['status']
      if status
        ed = box.parent()
        leg = box.closest('fieldset').find('legend')
        msg = leg.find '.name-messages'
        unless msg[0]
          msg = $('<span class="name-messages"></span>')
          leg.append msg
        ed.removeClass 'real-name virtual-name known-name'

        # use id to avoid warning when renaming to name variant
        slot_id = box.slot().data 'cardId'
        if status != 'unknown' and !(slot_id && parseInt(slot_id) == data['id'])
          ed.addClass status + '-name known-name'
          link =
          # wish coffee would let me use  a ? b : c syntax here
          qualifier = if status == 'virtual'
            'in virtual'
          else
            'already in'
          msg.html '"<a href="' + decko.path(data['url_key']) + '">' +
                   name + '</a>" ' + qualifier + ' use'
        else
          msg.html ''

  $('body').on 'click', '.render-error-link', (event) ->
    msg = $(this).closest('.render-error').find '.render-error-message'
    msg.show()
#    msg.dialog()
    event.preventDefault()


  $('card-view-placeholder').each ->
    $this = $(this)
    $.get $this.data("url"), (data, status) ->
      $this.replaceWith data

# important: this prevents jquery-mobile from taking over everything
# $( document ).on "mobileinit", ->
#   $.extend $.mobile , {
#     #autoInitializePage: false
#     #ajaxEnabled: false
#   }


snakeCase = (str)->
  str.replace /([a-z])([A-Z])/g, (match) -> match[0] + '_' +
              match[1].toLowerCase()

warn = (stuff) -> console.log stuff if console?

decko.slotReady (slot) ->
  slot.find('._disappear').delay(5000).animate(
    height: 0, 1000, -> $(this).hide())

  if slot.hasClass("_refresh-timer")
    setTimeout(
      -> $.get slot.data("refresh-url"), (data, status) ->
        slot.setSlotContent data
        #new_slot = slot.replaceWith data
        #new_slot.trigger('slotReady')
      2000
    )

  # this finds ._modal-slots and moves them to the end of the body
  # this allows us to render modal slots inside slots that call them and yet
  # avoid associated problems (eg nested forms and unintentional styling)
  # note: it deletes duplicate modal slots
  slot.find('._modal-slot').each ->
    mslot = $(this)
    if $.find("body #" + mslot.attr("id")).length > 1
      mslot.remove()
    else
      $("body").append mslot
