"use strict"

# Main directive, that just publish a controller
# ---------- Some necessary internal functions from angular.js ----------
# must invoke on object to keep the right this
#'9'
#'Z'
# ---------- Some initializations at the beginning of ngRepeat factory ----------
# ---------- Internal function at the end of ngRepeat factory ----------
# ---------- Add watch, extracted into a function to call it not only on the element but also on its children ----------

#watch props
# current position of the node

# Same as lastBlockMap but it has the current state. It will become the
# lastBlockMap on the next iteration.
# key/value of iteration
# last object information {scope, element, id}

# if object, extract keys, sort them and use to determine order of iteration over obj props

# locate existing items
# restore lastBlockMap
# This is a duplicate and we need to throw an error
# new never before seen block
# remove existing items
# lastBlockMap is our own object so we don't need to use special hasOwnPropertyFn

# we are not using forEach for perf reasons (trying to avoid #call)
# if we have already seen this object, then we need to reuse the
# associated scope/element
# existing item which got moved
# new item which we don't know about
# assign key, value, and $index to the locals so that they can be used in hash functions

# Store a list of elements from previous run. This is a hash where key is the item from the
# iterator, and the value is objects with following properties.
#   - scope: bound scope
#   - element: previous element.
#   - index: position
#lastBlockMap
#lastBlockMap

# Firefox requires some data

angular.module("angular.treerepeat", [])

.directive("frangTree", ($parse, $animate) ->
  restrict: "EA"

  controller: ($scope, $element) ->
    @insertChildren = null

    @init = (insertChildren) ->
      @insertChildren = insertChildren

    return
)

.directive("frangTreeRepeat", ($parse, $animate) ->

  hashKey = (obj) ->
    objType = typeof obj
    key = undefined
    if objType is "object" and obj isnt null
      if typeof (key = obj.$$hashKey) is "function"
        key = obj.$$hashKey()
      else key = obj.$$hashKey = nextUid()  if key is `undefined`
    else
      key = obj
    objType + ":" + key

  isArrayLike = (obj) ->
    return false  if not obj? or isWindow(obj)
    length = obj.length
    return true  if obj.nodeType is 1 and length
    isString(obj) or isArray(obj) or length is 0 or typeof length is "number" and length > 0 and (length - 1) of obj

  isWindow = (obj) ->
    obj and obj.document and obj.location and obj.alert and obj.setInterval

  isString = (value) ->
    typeof value is "string"

  isArray = (value) ->
    toString.apply(value) is "[object Array]"

  nextUid = ->
    index = uid.length
    digit = undefined
    while index
      index--
      digit = uid[index].charCodeAt(0)
      if digit is 57
        uid[index] = "A"
        return uid.join("")
      if digit is 90
        uid[index] = "0"
      else
        uid[index] = String.fromCharCode(digit + 1)
        return uid.join("")
    uid.unshift "0"
    uid.join ""

  assertNotHasOwnProperty = (name, context) ->
    throw ngMinErr("badname", "hasOwnProperty is not a valid {0} name", context)  if name is "hasOwnProperty"

  minErr = (module) ->
    ->
      code = arguments_[0]
      prefix = "[" + ((if module then module + ":" else "")) + code + "] "
      template = arguments_[1]
      templateArgs = arguments_
      stringify = (obj) ->
        if isFunction(obj)
          return obj.toString().replace(RegExp(" \\{[\\s\\S]*$"), "")
        else if isUndefined(obj)
          return "undefined"
        else return JSON.stringify(obj)  unless isString(obj)
        obj

      message = undefined
      i = undefined
      message = prefix + template.replace(/\{\d+\}/g, (match) ->
        index = +match.slice(1, -1)
        arg = undefined
        if index + 2 < templateArgs.length
          arg = templateArgs[index + 2]
          if isFunction(arg)
            return arg.toString().replace(RegExp(" ?\\{[\\s\\S]*$"), "")
          else if isUndefined(arg)
            return "undefined"
          else return toJson(arg)  unless isString(arg)
          return arg
        match
      )
      message = message + "\nhttp://errors.angularjs.org/" + version.full + "/" + ((if module then module + "/" else "")) + code
      i = 2
      while i < arguments_.length
        message = message + ((if i is 2 then "?" else "&")) + "p" + (i - 2) + "=" + encodeURIComponent(stringify(arguments_[i]))
        i++
      new Error(message)

  getBlockElements = (block) ->
    return jqLite(block.startNode)  if block.startNode is block.endNode
    element = block.startNode
    elements = [element]
    loop
      element = element.nextSibling
      break  unless element
      elements.push element
      break unless element isnt block.endNode
    jqLite elements

  addRepeatWatch = ($scope, $element, _lastBlockMap, valueIdentifier, keyIdentifier, rhs, trackByIdExpFn, trackByIdArrayFn, trackByIdObjFn, linker, expression) ->
    lastBlockMap = _lastBlockMap

    $scope.$watchCollection rhs, ngRepeatAction = (collection) ->
      index = undefined
      length = undefined
      previousNode = $element[0]
      nextNode = undefined
      nextBlockMap = {}
      arrayLength = undefined
      childScope = undefined
      key = undefined
      value = undefined
      trackById = undefined
      trackByIdFn = undefined
      collectionKeys = undefined
      block = undefined
      nextBlockOrder = []
      elementsToRemove = undefined

      if isArrayLike(collection)
        collectionKeys = collection
        trackByIdFn = trackByIdExpFn or trackByIdArrayFn
      else
        trackByIdFn = trackByIdExpFn or trackByIdObjFn
        collectionKeys = []
        for key of collection
          collectionKeys.push key  if collection.hasOwnProperty(key) and key.charAt(0) isnt "$"
        collectionKeys.sort()

      arrayLength = collectionKeys.length
      length = nextBlockOrder.length = collectionKeys.length
      index = 0
      while index < length
        key = (if (collection is collectionKeys) then index else collectionKeys[index])
        value = collection[key]
        trackById = trackByIdFn(key, value, index)
        assertNotHasOwnProperty trackById, "`track by` id"
        if lastBlockMap.hasOwnProperty(trackById)
          block = lastBlockMap[trackById]
          delete lastBlockMap[trackById]

          nextBlockMap[trackById] = block
          nextBlockOrder[index] = block
        else if nextBlockMap.hasOwnProperty(trackById)
          forEach nextBlockOrder, (block) ->
            lastBlockMap[block.id] = block  if block and block.startNode
            return

          throw ngRepeatMinErr("dupes", "Duplicates in a repeater are not allowed. Use 'track by' expression to specify unique keys. Repeater: {0}, Duplicate key: {1}", expression, trackById)
        else
          nextBlockOrder[index] = id: trackById
          nextBlockMap[trackById] = false
        index++

      for key of lastBlockMap
        if lastBlockMap.hasOwnProperty(key)
          block = lastBlockMap[key]
          elementsToRemove = getBlockElements(block)
          $animate.leave elementsToRemove
          forEach elementsToRemove, (element) ->
            element[NG_REMOVED] = true
            return

          block.scope.$destroy()

      index = 0
      length = collectionKeys.length

      while index < length
        key = (if (collection is collectionKeys) then index else collectionKeys[index])
        value = collection[key]
        block = nextBlockOrder[index]
        previousNode = nextBlockOrder[index - 1].endNode  if nextBlockOrder[index - 1]

        if block.startNode
          childScope = block.scope
          nextNode = previousNode
          loop
            nextNode = nextNode.nextSibling
            break unless nextNode and nextNode[NG_REMOVED]
          $animate.move getBlockElements(block), null, jqLite(previousNode)  unless block.startNode is nextNode
          previousNode = block.endNode
        else
          childScope = $scope.$new()

        childScope[valueIdentifier] = value
        childScope[keyIdentifier] = key  if keyIdentifier
        childScope.$index = index
        childScope.$first = (index is 0)
        childScope.$last = (index is (arrayLength - 1))
        childScope.$middle = not (childScope.$first or childScope.$last)
        childScope.$odd = not (childScope.$even = index % 2 is 0)

        unless block.startNode
          linker childScope, (clone) ->
            clone[clone.length++] = document.createComment(" end ngRepeat: " + expression + " ")
            $animate.enter clone, null, jqLite(previousNode)
            previousNode = clone
            block.scope = childScope
            block.startNode = (if previousNode and previousNode.endNode then previousNode.endNode else clone[0])
            block.endNode = clone[clone.length - 1]
            nextBlockMap[block.id] = block
            return

        index++

      lastBlockMap = nextBlockMap

  uid = [
    "0"
    "0"
    "0"
  ]

  jqLite = angular.element
  forEach = angular.forEach
  NG_REMOVED = "$$NG_REMOVED"
  ngRepeatMinErr = minErr("ngRepeat")
  ngMinErr = minErr("ng")
  toString = Object::toString
  isFunction = angular.isFunction
  isUndefined = angular.isUndefined
  toJson = angular.toJson

  restrict: "A"
  transclude: "element"
  priority: 1000
  terminal: true
  require: "^frangTree"

  compile: (element, attr, linker) ->

    ($scope, $element, $attr, ctrl) ->

      expression = $attr.frangTreeRepeat
      match = expression.match(/^\s*(.+)\s+in\s+(.*?)\s*(\s+track\s+by\s+(.+)\s*)?$/)
      trackByExp = undefined
      trackByExpGetter = undefined
      trackByIdExpFn = undefined
      trackByIdArrayFn = undefined
      trackByIdObjFn = undefined
      lhs = undefined
      rhs = undefined
      valueIdentifier = undefined
      keyIdentifier = undefined
      hashFnLocals = $id: hashKey

      throw ngRepeatMinErr("iexp", "Expected expression in form of '_item_ in _collection_[ track by _id_]' but got '{0}'.", expression)  unless match

      lhs = match[1]
      rhs = match[2]
      trackByExp = match[4]

      if trackByExp
        trackByExpGetter = $parse(trackByExp)
        trackByIdExpFn = (key, value, index) ->
          hashFnLocals[keyIdentifier] = key  if keyIdentifier
          hashFnLocals[valueIdentifier] = value
          hashFnLocals.$index = index
          trackByExpGetter $scope, hashFnLocals
      else
        trackByIdArrayFn = (key, value) ->
          hashKey value

        trackByIdObjFn = (key) ->
          key

      match = lhs.match(/^(?:([\$\w]+)|\(([\$\w]+)\s*,\s*([\$\w]+)\))$/)

      throw ngRepeatMinErr("iidexp", "'_item_' in '_item_ in _collection_' should be an identifier or '(_key_, _value_)' expression, but got '{0}'.", lhs)  unless match

      valueIdentifier = match[3] or match[1]
      keyIdentifier = match[2]
      lastBlockMap = {}

      addRepeatWatch $scope, $element, {}, valueIdentifier, keyIdentifier, rhs, trackByIdExpFn, trackByIdArrayFn, trackByIdObjFn, linker, expression

      ctrl.init ($scope, $element, collection) ->
        addRepeatWatch $scope, $element, {}, valueIdentifier, keyIdentifier, collection, trackByIdExpFn, trackByIdArrayFn, trackByIdObjFn, linker, expression
)

.directive("frangTreeInsertChildren", ->
  restrict: "EA"
  require: "^frangTree"

  link: (scope, element, attrs, ctrl) ->
    comment = document.createComment("treeRepeat")
    element.append comment

    console.log ctrl

    ctrl.insertChildren scope, angular.element(comment), attrs.frangTreeInsertChildren
)

.directive("frangTreeDrag", ($parse) ->
  restrict: "A"
  require: "^frangTree"

  link: (scope, element, attrs, ctrl) ->
    el = element[0]
    parsedDrag = $parse(attrs.frangTreeDrag)
    el.draggable = true

    el.addEventListener "dragstart", ((e) ->
      e.stopPropagation()  if e.stopPropagation
      e.dataTransfer.effectAllowed = "copy"
      e.dataTransfer.setData "Text", "nothing"
      element.addClass "tree-drag"
      ctrl.dragData = parsedDrag(scope)
      false
    ), false

    el.addEventListener "dragend", ((e) ->
      e.stopPropagation()  if e.stopPropagation
      element.removeClass "tree-drag"
      ctrl.dragData = null
      false
    ), false
)

.directive("frangTreeDrop", ($parse) ->
  restrict: "A"
  require: "^frangTree"

  link: (scope, element, attrs, ctrl) ->
    el = element[0]
    parsedDrop = $parse(attrs.frangTreeDrop)
    parsedAllowDrop = $parse(attrs.frangTreeAllowDrop or "true")

    el.addEventListener "dragover", ((e) ->
      if parsedAllowDrop(scope,
        dragData: ctrl.dragData
      )
        e.stopPropagation()  if e.stopPropagation
        e.dataTransfer.dropEffect = "move"
        element.addClass "tree-drag-over"
        
        # allow drop
        e.preventDefault()  if e.preventDefault
      false
    ), false

    el.addEventListener "dragenter", ((e) ->
      if parsedAllowDrop(scope,
        dragData: ctrl.dragData
      )
        e.stopPropagation()  if e.stopPropagation
        element.addClass "tree-drag-over"
        
        # allow drop
        e.preventDefault()  if e.preventDefault
      false
    ), false

    el.addEventListener "dragleave", ((e) ->
      if parsedAllowDrop(scope,
        dragData: ctrl.dragData
      )
        e.stopPropagation()  if e.stopPropagation
        element.removeClass "tree-drag-over"
      false
    ), false

    el.addEventListener "drop", ((e) ->
      if parsedAllowDrop(scope,
        dragData: ctrl.dragData
      )
        e.stopPropagation()  if e.stopPropagation
        element.removeClass "tree-drag-over"
        scope.$apply ->
          parsedDrop scope,
            dragData: ctrl.dragData

          return

        ctrl.dragData = null
        e.preventDefault()  if e.preventDefault
      false
    ), false
)
