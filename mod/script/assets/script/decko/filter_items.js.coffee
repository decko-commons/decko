# FILTERED LIST / ITEMS INTERFACE
# (fancy pointer ui)

$(window).ready ->
# add all selected items
  $("body").on "click", "._filter-items ._add-selected", ->
    filterBox(this).updateAddSelectedUrl()

  # select all visible filtered items
  $("body").on "click", "._select-all", ->
    filterBox(this).selectAll()
    $(this).prop "checked", false

  # deselect all selected items
  $("body").on "click", "._deselect-all", ->
    filterBox(this).deselectAll()
    $(this).prop "checked", true

  $("body").on "click", "._filter-items ._unselected input._checkbox-list-checkbox", ->
    filterBox(this).selectAndUpdate this

  $("body").on "click", "._filter-items ._selected input._checkbox-list-checkbox", ->
    filterBox(this).deselectAndUpdate this

  # this is inside the list, not the filter box.  move elsewhere?
  $('body').on 'click', '._filtered-list-item-delete', ->
    $(this).closest('li').remove()

filterBox = (el) -> new FilterBox el

class FilterBox
  constructor: (el) ->
    @box = $(el).closest "._filter-items" # the ui box
    @bin = @box.find "._selected-bin"
    @selected_items = @box.find "._selected-item-list"
    @help_text = @box.find "._filter-help"

    # this button contains the data about the form that opened the filter-items interface.
    @addSelectedButton = @box.find "._add-selected"
    @deselectAllLink = @box.find "._deselect-all"

  selectAll:->
    t = this
    @box.find("._unselected input._checkbox-list-checkbox").each -> t.select this
    @update()

  deselectAll:->
    t = this
    @box.find("._selected input._checkbox-list-checkbox").each -> t.deselect this
    @update()

  select: (checkbox) ->
    checkbox = $(checkbox)
    checkbox.prop "checked", true
    @bin.append checkbox.slot()

  deselect: (checkbox) ->
    $(checkbox).slot().remove()

  selectAndUpdate: (checkbox) ->
    @select checkbox
    @update()

  deselectAndUpdate: (checkbox) ->
    @deselect checkbox
    @update()

  update:->
    @trackSelectedIds()
    f = new decko.filter @box.find('._filter-widget')
    f.update()
    @updateSelectedCount()
    @updateUnselectedCount()

  updateAddSelectedUrl: ()->
    @addSelectedButton.attr "href", @addSelectedUrl()

  newContent: ->
    t = this
    $.map(t.prefilteredIds().concat(t.selectedIds()), (id) -> "~" + id).join "\n"

  sourceSlot: ->
    @addSelectedButton.slot()

  addSelectedUrl: ->
    slot = @sourceSlot()
    query =
      assign: true
      view: slot.data("slot")["view"]
      card:
        content: @newContent()
        type_id: slot.data("cardTypeId")
    path = @addSelectedButton.attr("href") + "&" + $.param(query)
    decko.slotPath path, slot

  trackSelectedIds: ->
    ids = @prefilteredIds().concat @selectedIds()
    @box.find("._not-ids").val ids.toString()

  prefilteredIds:-> @prefilteredData "cardId"
  prefilteredNames:-> @prefilteredData "cardName"

  prefilteredData: (field) ->
    selector = @addSelectedButton.data "itemSelector"
    @arrayFromField @sourceSlot().find(selector), field

  selectedIds:-> @selectedData "cardId"
  selectedNames:-> @selectedData "cardName"
  selectedData: (field) -> @arrayFromField @bin.children(), field
  arrayFromField: (rows, field) -> rows.map( -> $(this).data field ).toArray()

  updateUnselectedCount: ->
    count = @box.find("._search-checkbox-list").children().length
    @box.find("._unselected-items").html count
    @box.find("._select-all").attr "disabled", count > 0

  updateSelectedCount: ->
    count = @bin.children().length
    @box.find("._selected-items").html count
    @deselectAllLink.attr "disabled", count == 0
    if count > 0
      @addSelectedButton.removeClass "disabled"
    else
      @addSelectedButton.addClass "disabled"

    @updateSelectedSectionVisibility count > 0

  updateSelectedSectionVisibility: (items_present) ->
    if items_present
      @selected_items.show()
      @help_text.hide()
    else
      @selected_items.hide()
      @help_text.show()
