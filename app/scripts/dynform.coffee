'use strict';

angular.module('dynform.services', ['app'])

.directive('dynModelValue', [
  '$interpolate'
  '$compile'
  '$parse'
  'sfSelect'
  'sfPath'

  ($interpolate, $compile, $parse, sfSelect, sfPath) ->
    restrict: 'A'
#    terminal: true
    priority: 100000

    link: ($scope, element, attrs) ->
      element.removeAttr('dyn-model-value')

      f = $scope.form
      if f
        if f.key?
          if type(f.key) is 'array'
            s = f.key.join('.')
          else
            s = f.key
          element.attr('name', s)

      $compile(element)($scope)
])

.directive('sfArray', [
  '$parse'
  'schemaForm'
  'sfSelect'
  'sfPath'

  ($parse, schemaForm, sfSelect, sfPath) ->
    restrict: 'A'
    priority: -1

    link: ($scope, element, attrs) ->
      form = $parse(attrs.sfArray)($scope)
      $scope.$watch('model' + sfPath.normalize(form.key), (val) ->
        origArray = sfSelect(form.key, $scope.model)
        array = _.clone(sfSelect(form.key, $scope.model))
        if array
          array.splice(0, array.length)
          for a in origArray
            array.push(a)
      )
])

.directive('dynForm', [
  'dynFormRow'

  (dynFormRow) ->
    restrict: 'E'
    require: ['?sfSchema', '?sfForm', '?sfModel', '?sfFormDom']

    link: ($scope, $element, attrs) ->
      $scope.evalInParentScope = (expr, locals) ->
        return $scope.$parent.$eval(expr, locals)

      $scope.modelName = attrs.sfModel
      $scope.formName = attrs.sfFormDom
      $scope.formCtrl = (if $scope.formName then $scope[$scope.formName] else null)

      $scope.getForm = () ->
        return (if type($scope.form) is 'array' then $scope.form[0] else $scope.form)

      $scope.$watch('form', (newValue, oldValue) ->
        if !_.isEqual(newValue, oldValue)
          console.log "$watch form", $scope
          if !_.isEmpty($scope.model)
            $scope.tryEdit()
      )

      $scope.$watch('model', (newValue, oldValue) ->
        if !_.isEqual(newValue, oldValue)

          console.log $scope

          if !$scope.model.rows?
            dynFormRow.init($scope, $scope.model)

            $scope.hasRows = () ->
              return false

            $scope.canEdit = () ->
              return (if $scope.getForm().canEdit == false then false else true)

            $scope.canCreate = () ->
              return false

            $scope.canDelete = () ->
              return false

            $scope.canMove = () ->
              return false

            console.log "$watch model", $scope
            if !_.isEmpty($scope.form)
              $scope.tryEdit()

          else

            $scope.hasRows = () ->
              return true

            $scope.tryEdit = (cb) ->
              cb(false) if cb

            $scope.canEdit = () ->
              return (if $scope.getForm().canEdit == false then false else true)

            $scope.canCreate = () ->
              return (if $scope.getForm().canCreate == false then false else true)

            $scope.canDelete = () ->
              return (if $scope.getForm().canDelete == false then false else true)

            $scope.canMove = () ->
              return (if $scope.getForm().canMove == false then false else true)

            $scope.create = (cb) ->
              if $scope.canCreate() and $scope.model
                if $scope.model.create
                  $scope.model.create((r) ->
                    if r
                      if $scope.rows.push?
                        $scope.rows.push(r)
                      idx = $scope.rows.length - 1
                      console.log "create", idx, r, $scope.rows
        #              $scope.on('create', r, idx)
                      $scope.tryEdit(idx)
                      cb(r) if cb
                  )
                else
        #          if $scope.getForm().blank
        #            $scope.updateRows([])
                  $scope.rows.push({})
                  idx = $scope.rows.length - 1
                  console.log "create", idx, r, $scope.rows
        #          $scope.on('create', r, idx)
                  $scope.tryEdit(idx)
                  cb({}) if cb

            $scope.modified = () ->
              for r in $scope.model.rows
                if r.$scope and r.$scope.modified()
                  return true
              return false

          $scope.hasActions = () ->
            return $scope.canEdit() or $scope.canCreate() or $scope.canDelete() or $scope.canMove()

          $scope.onSubmit = () ->
            $scope.$broadcast('schemaFormValidate')
      )
])

.factory('dynFormRow', [
  () ->
    init: ($scope, row) ->
      $scope.row = row
      $scope.master = null
      $scope.state = ''
      $scope.idx = (if $scope.model.rows? then $scope.model.rows.indexOf($scope.row) else -1)

      $scope.modified = () ->
        if $scope.master
          return _.isEqual($scope.getRow(), $scope.master)
        else
          return false

      $scope.hasState = (_state) ->
        $scope.state.indexOf(_state) != -1

      $scope.addState = (_state) ->
        if !$scope.hasState(_state)
          $scope.state += _state

      $scope.delState = (_state) ->
        if $scope.hasState(_state)
          $scope.state = $scope.state.replace(_state, '')

      $scope.isEditing = () ->
        return $scope.hasState('e')

      $scope.isDeleted = () ->
        return $scope.hasState('d')

      $scope.getRow = () ->
        result = {}
        if $scope.row.plain
          r = $scope.row.plain()
        else
          r = $scope.row
        if r
          for k of r
            result[k] = r[k]
        return result

      $scope.setRow = (v) ->
        if $scope.row.plain
          r = $scope.row.plain()
        else
          r = $scope.row
        if r
          for k of r
            if v[k]
              $scope.row[k] = v[k]
            else
              delete $scope.row[k]

      $scope.tryEdit = (cb) ->
        console.log "tryEdit", $scope.idx, $scope.row, $scope.getForm()
        if $scope.getForm().editMode == 'always'
          if $scope.getForm().blank and $scope.model
            if $scope.model.create
              $scope.model.create((r) ->
                $scope.setRow(r)
                $scope.edit(cb)
              )
            else
              $scope.edit(cb)
          else
            $scope.edit(cb)
        else
          cb(false) if cb

      $scope.edit = (forceInline, cb) ->
        if type(forceInline) is 'function'
          cb = forceInline
          cb = null
        if !$scope.isEditing() and $scope.canEdit()
          $scope.cancel(->
            $scope.master = _.cloneDeep($scope.getRow())
            $scope.addState('e')
            console.log "edit", $scope.idx, $scope.master
            cb(true) if cb

  #          if !forceInline? and $scope.editModal()
  #            $scope.addState('a')
  #            $injector.get('dynModal').showModalForm({formDefinition: $scope.getForm().modal, model: $scope.row}, (mr) ->
  #              if mr
  #                $scope.save(->
  #                  cb(true) if cb
  #                )
  #              else
  #                $scope.cancel(->
  #                  cb(false) if cb
  #                )
  #            )
  #          else
  #            cb(true) if cb
          )
        else
          cb(false) if cb

      $scope.remove = (cb) ->
        console.log "remove", $scope.idx, $scope.row
        if $scope.canDelete() and $scope.model
          $scope.cancel()
          if $scope.model.remove
            if $scope.row.fromServer
              $scope.model.remove($scope.row, ->
  #              $scope.on('remove')
                $scope.rows.splice($scope.idx, 1)
                $scope.tryEdit(->
                  cb(true) if cb
                )
              )
            else
  #            $scope.on('remove')
              $scope.rows.splice($scope.idx, 1)
              $scope.tryEdit(->
                cb(true) if cb
              )
          else
  #          $scope.on('remove')
            $scope.rows.splice($scope.idx(), 1)
            $scope.tryEdit(->
              cb(true) if cb
            )
        else
          cb(false) if cb

      $scope.save = (cb) ->
        console.log "save", $scope.idx, $scope.master, $scope.row
        $scope.$broadcast('schemaFormValidate')
        if $scope.hasSuccess()
          if $scope.modified()
            $scope.delState('a')
            $scope.delState('e')
            $scope.addState('m')
#            $scope.removeErrors()
            $scope.ngModel.$setPristine()
            if $scope.model.update?
              $scope.model.update($scope.row, (result) ->
                if result
                  $scope.setRow(result)
#                $scope.on('save', result)
                $scope.master = null
                $scope.tryEdit(->
                  cb(true) if cb
                )
              )
            else
              cb(false) if cb
          else
            cb(true) if cb
        else
          cb(false) if cb


      $scope.cancel = (cb) ->
        $scope.delState('a')
        $scope.delState('e')
        if $scope.master
          $timeout(->
            $scope.$apply(->
              console.log "cancel", $scope.idx
              $scope.setRow($scope.master)
#              $scope.on('cancel')
#              $scope.removeErrors()
              $scope.ngModel.$setPristine()
              $scope.master = null
              $scope.tryEdit(->
                cb(true) if cb
              )
            )
          )
        else
          cb(false) if cb

])

.directive('dynFormRow', [
  'dynFormRow'
  '$parse'

  (dynFormRow, $parse) ->
    restrict: 'A'
    scope: {
      'model': '='
      'modelName': '@'
      'formName': '@'
      'formCtrl': '@'
    }
    link: ($scope, element, attrs, controllers) ->
      dynFormRow.init($scope, $parse(attrs.dynFormRow)($scope))
      $scope.row.$scope = $scope
])

.controller('DynamicFormCtrl', [
  '$scope'
  'dynFormRow'

  ($scope, dynFormRow) ->

#    $scope.$watch('build', (newValue, oldValue) ->
#      if newValue == true
#        $scope.tryEdit()
#    )
])
