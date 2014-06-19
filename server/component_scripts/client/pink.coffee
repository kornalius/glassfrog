return {
  render: (node, c) ->
    if c
      e = angular.element('#component-icon_' + @_id)
    else
      e = angular.element('#node-label_' + node.$data.parent._id)
    e.addClass('pink')
#    s = if e.attr('style') then e.attr('style') else ""
#    e.attr('style', s + 'color: #e578d5; ')

  generate: (node) ->
    return ""
}
