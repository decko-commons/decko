decko.slotReady (slot, slotter) ->
  slot.updateBridge(false, slotter)

  links = slot.find('ul._auto-single-select > li.nav-item > a.nav-link')
  if links.length == 1
    $(links[0]).click()

jQuery.fn.extend
  # overlayClosed=true means the bridge update was
  # triggered by closing an overlay
  updateBridge: (overlayClosed=false, slotter) ->
    return unless @closest(".bridge").length > 0
    if @data("breadcrumb")
      @updateBreadcrumb()
    else if slotter and $(slotter).data("breadcrumb")
      $(slotter).updateBreadcrumb()

    if overlayClosed
      $(".bridge-pills > .nav-item > .nav-link.active").removeClass("active")

  updateBreadcrumb: () ->
    bc_item = $(".modal-header ._bridge-breadcrumb li:last-child")
    bc_item.text(this.data("breadcrumb"))
    bc_item.attr("class", "breadcrumb-item active #{this.data('breadcrumb-class')}")




