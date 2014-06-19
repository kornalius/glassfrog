return {
  render: (node, c) ->
    if !c
      e = angular.element('#node-label_' + node._id)
      s = if e.attr('style') then e.attr('style') else ""
      e.attr('style', s + 'font-weight: bold; ')

  generate: (node) ->
    s = "schema" + '\n'
    c = node.$data.component
    if node.$data.hasChildren()
      for n in node.$data.childrenOfKind('Field')
        if n.$data.hasClientCode()
          c = n.$data.component
          s += n.$data.generate() + '\n'
    return s
}
