jQuery.fn.extend
  findCard: (id) -> @find("[data-card-id='" + id + "']")

  isMain: -> @slot().parent('#main')[0]

  cardMark: ->
    if @data('cardId') then "~#{@data('cardId')}" else @data("cardName")

  isMainOrMainModal: ->
    el = $(this)
    el = el.slotOrigin("modal") if el.closest(".modal")[0]
    el && el.isMain()

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
