decko.slot.ready (slot, slotter) ->
  slot.updateBoard(false, slotter)

  links = slot.find('ul._auto-single-select > li.nav-item > a.nav-link')
  if links.length == 1
    $(links[0]).click()

jQuery.fn.extend
  # overlayClosed=true means the board update was
  # triggered by closing an overlay
  updateBoard: (overlayClosed=false, slotter) ->
    return unless @closest(".board").length > 0
    if @data("breadcrumb")
      @updateBreadcrumb()
    else if slotter and $(slotter).data("breadcrumb")
      $(slotter).updateBreadcrumb()

    if overlayClosed
      $(".board-pills > .nav-item > .nav-link.active").removeClass("active")

  updateBreadcrumb: () ->
    bc_item = $(".modal-header ._board-breadcrumb li:last-child")
    bc_item.text(this.data("breadcrumb"))
    bc_item.attr("class", "breadcrumb-item active #{this.data('breadcrumb-class')}")

$(window).ready ->
  $('body').on "select2:select", "._close-rule-overlay-on-select", (event) ->
    $(".overlay-container > ._overlay.card-slot.overlay_rule-view.RULE").removeOverlay()

  $('body').on "click", "._update-history-pills", (event) ->
    $(this).closest(".slotter").data("update-foreign-slot", ".card-slot.history_tab-view")
