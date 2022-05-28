decko.slotReady (slot) ->
  slot.find('card-view-placeholder').each ->
    $place = $(this)
    return if $place.data("loading")

    $place.data "loading", true
    $.get $place.data("url"), (data, _status) ->
      $place.replaceWith data

  slot.find('._disappear').delay(5000).animate(
    height: 0, 1000, -> $(this).hide())
