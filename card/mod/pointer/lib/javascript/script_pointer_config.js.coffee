$.extend decko.editorContentFunctionMap,
    '.pointer-select': ->
      pointerContent @val()
    '.pointer-multiselect': ->
      pointerContent @val()
    '.pointer-radio-list': ->
      pointerContent @find('input:checked').val()
    '.pointer-list-ul': ->
      pointerContent @find('input').map( -> $(this).val() )
    '.pointer-checkbox-list': ->
      pointerContent @find('input:checked').map( -> $(this).val() )
    '.pointer-select-list': ->
      pointerContent @find('.pointer-select select').map( -> $(this).val() )
    '._pointer-filtered-list': ->
      pointerContent @find('._filtered-list-item').map( -> $(this).data('cardName') )
    # can't find evidence that the following is in use: #efm
    # '.pointer-mixed': ->
    #   element = '.pointer-checkbox-sublist input:checked,\
    #             .pointer-sublist-ul input'
    #   pointerContent @find(element).map( -> $(this).val() )
    # must happen after pointer-list-ul, I think
    '.perm-editor': -> permissionsContent this

decko.editorInitFunctionMap['.pointer-list-editor'] = ->
  @sortable({handle: '.handle', cancel: ''})
  decko.initPointerList @find('input')

decko.editorInitFunctionMap['._pointer-filtered-list'] = ->
  @sortable({handle: '._handle', cancel: ''})

$.extend decko,
  initPointerList: (input) ->
    decko.initAutoCardPlete input

  initAutoCardPlete: (input) ->
    optionsCard = input.data 'options-card'
    return unless !!optionsCard
    url = decko.rootPath + '/' + optionsCard + '.json?view=name_complete'
    input.autocomplete { source: decko.prepUrl(url) }

  pointerContent: (vals) ->
    list = $.map $.makeArray(vals), (v) -> if v then '[[' + v + ']]'
    $.makeArray(list).join "\n"

pointerContent = (vals) ->
  decko.pointerContent vals
  # deprecated. backwards compatibility

permissionsContent = (ed) ->
  return '_left' if ed.find('#inherit').is(':checked')
  groups = ed.find('.perm-group input:checked').map( -> $(this).val() )
  indivs = ed.find('.perm-indiv input'        ).map( -> $(this).val() )
  pointerContent $.makeArray(groups).concat($.makeArray(indivs))
