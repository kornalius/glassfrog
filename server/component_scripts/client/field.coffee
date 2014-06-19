return {
  generate: (node) ->
    s = "field" + '\n'
    c = node.$data.component
    if node.$data.hasChildren()
      for n in node.$data.childrenOfKind(['Attribute', 'Validator'])
        if n.$data.hasClientCode()
          c = n.$data.component
          s += n.$data.generate() + '\n'
    return s
}
