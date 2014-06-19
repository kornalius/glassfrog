return {
  render: (node, c) ->
    if c
      e = angular.element('#component-icon_' + @_id)
    else
      e = angular.element('#node-label_' + node.$data.parent._id)
    e.addClass('gray')
#    s = if e.attr('style') then e.attr('style') else ""
#    e.attr('style', s + 'color: #a9a9a9; ')

  generate: (node) ->
    return ""
}
