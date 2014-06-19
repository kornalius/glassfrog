angular.module('nodes', ['app.globals', 'components'])

.factory('Node', [
  '$timeout'
  '$injector'
  '$document'
  'EditorNode'
  '$http'
  'Globals'

  ($timeout, $injector, $document, EditorNode, $http, globals) ->

    updateNode: (n) ->
      return n

    makeId: (n) ->
      $http({ method: 'GET', url: '/api/node/objectid' }).
        success((data, status, headers, config) ->
          n._id = data
        ).
        error((data, status, headers, config) ->
        )

    makeNode: (n) ->
      Node = $injector.get('Node')

      n.$data.states = ''

      if !n._id
        @makeId(n)

      n.$data.hasState = (s) ->
        @states.indexOf(s) > -1

      n.$data.addState = (s) ->
        if !@hasState(s)
          @states += s

      n.$data.delState = (s) ->
        i = @states.indexOf(s)
        if i != -1
          @states = @states.substr(0, i) + @states.substr(i + 1)

      n.$data.isModified = () ->
        return @hasState('m')

      n.$data.isNew = () ->
        return @hasState('n')

      n.$data.isDeleted = () ->
        return @hasState('d')

      n.$data.displayName = () ->
        if @node.name?
          if @isLink()
            n = @getLink()
            if n
              return n.name
          return @node.name
        else if @component
          return @component.name
        else
          return "Untitled"

      n.$data.canAdd = (c, child) ->
        if !child and @parent
          n = @parent
        else
          n = @node
        return n.$data and n.$data.component and n.$data.component.$data and n.$data.component.$data.doAccept(n, c)

      n.$data.add = (name, c, child) ->
        if c
          c = globals.Component_Data.getComponent(c)

        if c
          if child
            n = globals.Node_Data.makeNode({ name: (if name then name else null), component: c._id, parentId: @node._id })
            Node.makeNode(n)
            EditorNode.makeNode(n)
            if n.$data
              l = n.$data.getLast()
              if l
                n._order = l._order + 1
              else
                n._order = 0
          else
            n = globals.Node_Data.makeNode({ name: (if name then name else null), component: c._id, parentId: (if @parent then @parent._id else null)})
            Node.makeNode(n)
            EditorNode.makeNode(n)
            oo = @node._order
            if n.$data
              n.$data.reorder(oo, -1, true, 1)
            n._order = oo

          globals.Node_Data.rest.rows.push(n)

          if n.$data
            n.$data.addState('n')
            n.$data.addState('m')

      n.$data.remove = (no_reorder) ->
        if !@isSystem()
          @addState('m')
          @addState('d')
          for n in @children()
            if n.$data
              n.$data.remove(true)
          if !no_reorder
            @reorder(@node._order, -1, true, -1)

      n.$data.reorder = (from, to, siblings, dst) ->
        if siblings
          d = @getSiblings()
        else if globals.Node_Data and globals.Node_Data.rest
          d = globals.Node_Data.rest.rows
        else
          d = []
        for r in d
          if (from == -1 or r._order >= from) and (to == -1 or r._order <= to)
            r._order += dst
            if r.$data
              r.$data.addState('m')

      n.$data.getFirst = () ->
        p = null
        po = 1000000
        for r in @getSiblings()
          if r._order < po
            po = r._order
            p = r
        return p

      n.$data.getPrev = () ->
        p = null
        po = 0
        for r in @getSiblings()
          if r._order < @node._order and r._order > po
            po = r._order
            p = r
        return p

      n.$data.getNext = () ->
        p = null
        po = 1000000
        for r in @getSiblings()
          if r._order > @node._order and r._order < po
            po = r._order
            p = r
        return p

      n.$data.getLast = () ->
        p = null
        po = 0
        for r in @getSiblings()
          if r._order > po
            po = r._order
            p = r
        return p

      n.$data.canMoveUp = () ->
        @getPrev() != null

      n.$data.moveUp = () ->
        p = @getPrev()
        if p
          po = p._order
          p._order = o._order
          if p.$data
            p.$data.addState('m')
          @node._order = po
          @addState('m')

      n.$data.canMoveDown = () ->
        @getNext() != null

      n.$data.moveDown = () ->
        p = @getNext()
        if p
          po = p._order
          p._order = o._order
          if p.$data
            p.$data.addState('m')
          @node._order = po
          @addState('m')

      n.$data.canMove = (d, child) ->
        if !child and @parent
          n = @parent
        else
          n = @node

        return n.$data and n.$data.component and n.$data.component.$data and n.$data.component.$data.doAccept(n, d.$data.component)

      n.$data.move = (d, child) ->
        s = @node

        if child
          if s.$data
            s.parentId = d._id
            s.$data.parent = d
            l = s.$data.getLast()
            if l
              s._order = l._order + 1
            else
              s._order = 0
        else
          s.parentId = d.parentId
          if s.$data and d.$data
            s.$data.parent = d.$data.parent

          dst = 0
          if d._order < s._order
            dst = 1
            a1 = d._order
            a2 = s._order
            oo = a1
          else if d._order > s._order
            dst = -1
            a1 = s._order
            a2 = d._order - 1
            oo = a2

          if dst != 0
            if d.$data
              d.$data.reorder(a1, a2, true, dst)
              s._order = oo
              s.$data.addState('m')

      n.$data.addComponents = (components, child) ->
        for c in components
          if c
            c = globals.Component_Data.getComponent(c)
          if c
            @add(c.name, c, child)

      n.$data.setComponent = (c) ->
        if c
          c = globals.Component_Data.getComponent(c)

        if c
          @component = c
          @node.component = c._id
          @node.$save() # rest
          if c.children?
            cc = []
            for k in c.children.split(',')
              cc.push(globals.Component_Data.getComponent(k))
            @addComponents(cc, true)

      n.$data.generate = () ->
        if @component and @component.$data
          return @component.$data.generate(@node)
        else
          return ""

      n.$data.hasParentIcons = () ->
        for cn in @children()
          if cn.$data and cn.$data.component and cn.$data.component.$data and cn.$data.component.$data.parentIcon()
            return true
        return false

      return n

    restPush: (data, cb) ->
      that = @
      if globals.Node_Data and globals.Node_Data.rest
        globals.Node_Data.rest.push(data, (result) -> #rest
  #          for i in [0..globals.Node_Data.rest.rows.length - 1]
  #            if data._id == globals.Node_Data.rest.rows[i]._id
  #              globals.Node_Data.rest.rows[i] = result
  #              break
          cb(result) if cb
        )
      else
        cb(null) if cb

    restDelete: (data, cb) ->
      that = @
      if globals.Node_Data and globals.Node_Data.rest
        globals.Node_Data.rest.delete(data, (result) -> #rest
          id = data._id.toString()
          for i in [0..globals.Node_Data.rest.rows.length - 1]
            if globals.Node_Data.rest.rows[i]._id.toString() == id
              globals.Node_Data.rest.rows.splice(i)
              break
          cb(result) if cb
        )
      else
        cb(null) if cb

    restUpdate: (data, cb) ->
      that = @
      if globals.Node_Data and globals.Node_Data.rest
        globals.Node_Data.rest.update(data, (result) -> #rest
  #          for i in [0..globals.Node_Data.rest.rows.length - 1]
  #            if globals.Node_Data.rest.rows[i]._id == data._id
  #              globals.Node_Data.rest.rows[i] = globals.Node_Data.updateNode(result)
  #              that.updateNode(result)
  #              break
          cb(result) if cb
        )
      else
        cb(null) if cb

    refresh: (cb) ->
      console.log "Loading nodes..."
      that = @
      if globals.Node_Data and globals.Node_Data.rest
        $http({ method: 'GET', url: '/api/nodes' }).
          success((data, status, headers, config) ->
            if data
              globals.Node_Data.rest.rows = data
              for n in data
                delete n.$data
                globals.Node_Data.makeNode(n)
                that.makeNode(n)
                EditorNode.makeNode(n)
              $document.trigger("resize")
              cb(data) if cb
            else
              cb(null) if cb
          ).
          error((data, status, headers, config) ->
            cb(null) if cb
          )

    rebuild: (cb) ->
      that = @
      if globals.Node_Data
        cb(null) if cb
])
