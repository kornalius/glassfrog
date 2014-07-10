'use strict'

angular.module('select.services', ['app', 'app.globals'])

.controller('selectCtrl', [
  '$scope'
  'Globals'

  ($scope, globals) ->
#    f = $scope.field
#    if f and f.value? and f.fieldname? and !$scope.row[f.fieldname]?
#      $scope.row[f.fieldname] = f.value
])

.directive('select2', [
  '$document'
  '$window'
  '$timeout'
  '$parse'

  ($document, $window, $timeout, $parse) ->
    restrict: 'E'

    require: 'ngModel'
    priority: 1

    controller: 'selectCtrl'

    compile: (element, attrs) ->
      watch = undefined
      repeatOption = undefined
      repeatAttr = undefined

      repeatOption = element.find("optgroup[ng-repeat], optgroup[data-ng-repeat], option[ng-repeat], option[data-ng-repeat]")
      if repeatOption.length
        repeatAttr = repeatOption.attr("ng-repeat") or repeatOption.attr("data-ng-repeat")
        watch = jQuery.trim(repeatAttr.split("|")[0]).split(" ").pop()

      (scope, element, attrs, ctrl) ->

        return if !ctrl?

        scope.select2Data = null

        if attrs.field?
          field = $parse(attrs.field)(scope)
        else
          field =
            value: 0
            options: []
            config: {}

        convertToSelect2Model = (angular_data) ->
          model = []

          convert = (value, index) ->
            i = null
            t = null

            if angular.isObject(value) and Object.keys(value).length > 0
              if value.id != null and value.text?
                i = value.id
                t = value.text
              else if value.id != null
                i = value.id
              else if value.value != null and value.label?
                i = value.value
                t = value.label
              else if value.value != null
                i = value.value
            else if angular.isNumber(value)
              i = value
            else
              i = index
              t = value

            if t == null and scope.select2Data
              for s in scope.select2Data
                if s.id == i
                  t = s.text
                  break

            if i != null
              model.push(
                id: i
                text: t
              )

          convertArray = (angular_data) ->
            angular.forEach(angular_data, (value, index) ->
              convert(value, index)
            )

          if angular.isArray(angular_data)
            convertArray(angular_data)
          else
            convert(angular_data, 0)
            if model.length == 1
              model = model[0]

          return model

        convertRowsToSelect2Model = (rows) ->
          model = []
          angular.forEach(rows, (value, index) ->
            i = null
            t = null
            if angular.isObject(value) and Object.keys(value).length > 0
              if value.id != null and value.text?
                i = value.id
                t = value.text
              else if value.value != null and value.label?
                i = value.value
                t = value.label
              else
                i = if value._id != null then value._id else index
                t = value[(if c.displayField then c.displayField else (if c.field then c.field else 0))]
            else
              i = index
              t = value.toString()

            if i != null and t != null
              model.push(
                id: i
                text: t
              )
          )

          scope.select2Data = model
          return model

        convertToAngularModel = (select2_data) ->
          model = []
          if angular.isArray(select2_data)
            angular.forEach(select2_data, (value, index) ->
              model.push(value)
            )
          else
            model = select2_data

          return model

        c = field.config
        if !c?
          c = {}

        if c.url
          c = angular.extend(c,
            ajax:
              url: c.url
              dataType: if c.dataType? then c.dataType else 'json'
              cache: false
              data: (term, page) ->
                q = {}
                if term.length
                  q['$regexi_' + c.field] = "{0}".format(term)
                return q
              results: (data) ->
                results: convertRowsToSelect2Model(data.slice(1))
                text: 'text'

#            initSelection: (element, callback) ->
#              v = ctrl.$modelValue
#              callback(v) if callback

            sortResults: (results, container, query) ->
              f = (if c.displayField then c.displayField else (if c.field then c.field else 0))
              return results.sort((a, b) ->
                return -1 if a[f] < b[f]
                return 1 if a[f] > b[f]
                return 0 if a[f] == b[f]
              )

            formatResult: (item) ->
              pre = ""
              post = ""
              if c.display_pre
                pre = c.display_pre
              if c.display_post
                post = c.display_post
              return pre + item.text + post

            formatSelection: (item) ->
              pre = ""
              post = ""
              if c.display_sel_pre
                pre = c.display_sel_pre
              else if c.display_pre
                pre = c.display_pre
              if c.display_sel_post
                post = c.display_sel_post
              else if c.display_post
                post = c.display_post
              return pre + item.text + post
          )

        else if angular.isArray(field.options)
          c = angular.extend(
#            query: (query) ->
#              data = {results: []}
#              if scope.data
#                for d in scope.data
#                  data.results.push({id: d.id, text: d.text })
#              query.callback(data)

            data:
              results: convertRowsToSelect2Model(field.options)
              text: 'text'

#            initSelection: (element, callback) ->
#              v = ctrl.$modelValue
#              ctrl.$setViewValue(convertToSelect2Model(v))
#              callback(v) if callback

            sortResults: (results, container, query) ->
              return results.sort((a, b) ->
                return -1 if a.text < b.text
                return 1 if a.text > b.text
                return 0 if a.text == b.text
              )

            formatResult: (item) ->
              pre = ""
              post = ""
              if c.display_pre
                pre = c.display_pre
              if c.display_post
                post = c.display_post
              return pre + item.text + post

            formatSelection: (item) ->
              pre = ""
              post = ""
              if c.display_sel_pre
                pre = c.display_sel_pre
              else if c.display_pre
                pre = c.display_pre
              if c.display_sel_post
                post = c.display_sel_post
              else if c.display_post
                post = c.display_post
              return pre + item.text + post

          , c)

        if field.placeholder?
          c = angular.extend({placeholder: field.placeholder}, c)

        scope.options = angular.extend(
          placeholder: "Select something..."
          width: '100%'
          cache: false
        , c)

        if field.value? and field.fieldname? and !scope.row[field.fieldname]?
          scope.row[field.fieldname] = field.value

        scope.$watch(attrs.ngModel, (current, old) ->
          if current? and current isnt old
            ctrl.$render()
        , true)

        ctrl.$render = () ->
          viewValue = ctrl.$viewValue
          if angular.isString(viewValue)
            viewValue = viewValue.split(',')
            element.select2('data', convertToSelect2Model(viewValue))

        if watch
          scope.$watch(watch, (newVal, oldVal, scope) ->
            if angular.equals(newVal, oldVal)
              return

            $timeout(() ->
              element.select2('data', convertToSelect2Model(ctrl.$viewValue))
              element.trigger('change')
            )
          )

        element.bind("change", (e) ->
#          e.stopImmediatePropagation()

          if scope.$$phase || scope.$root.$$phase
            return

          scope.$apply(() ->
            ctrl.$setViewValue(convertToAngularModel(element.select2('data')))
          )
        )

        element.bind("$destroy", () ->
          element.select2("destroy")
        )

        element.on('select2-focus', (event) ->
          if $(this).data('select2-closed')
            $(this).data('select2-closed', false)
            return

          select2 = $(this).data('select2')
          if !select2.opened()
              select2.open()
#            element.trigger('focus')
        )

        element.on('select2-blur', (event) ->
#          $timeout(->
#            element.trigger('blur')
#          )
        )

        element.on('select2-loaded', (event) ->
#          console.log "select2-loaded", event.items
          ctrl.$render()
        )

        element.on('select2-open', (event) ->
#          element.select2('positionDropdown')
        )

        element.on('select2-close', (event) ->
          $(this).data('select2-closed', true)
#          element.select2('positionDropdown')
        )

        attrs.$observe('disabled', (value) ->
          element.select2('enable', !value)
        )

        attrs.$observe('readonly', (value) ->
          element.select2('readonly', !!value)
        )

        $timeout( ->
          element.select2(scope.options)
          v = ctrl.$modelValue
          if v
            c = scope.options
            if c.url?
              q = {}
              if angular.isArray(v)
                q['$in_' + c.field] = v.join(',')
              else
                q[c.field] = v
              $.ajax(
                url: c.url
                cache: false
                dataType: if c.dataType? then c.dataType else 'json'
                data: q
              ).success((data) ->
                element.select2('data', convertRowsToSelect2Model(data.slice(1)))
              )
            else
              element.select2('data', convertToSelect2Model(v))

          ctrl.$render()

#          $($window).scroll( ->
#            $(".select2-container.select2-dropdown-open").not($(this)).select2('positionDropdown')
#          )

#          if scope.options.multiple
#            ctrl.$setViewValue(convertToAngularModel(element.select2('data')))
        )
])
