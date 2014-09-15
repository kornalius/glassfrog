angular.module('ui.selectize', [])

.directive('selectize', [
  '$timeout'
  '$parse'

  ($timeout, $parse) ->
    restrict: 'A'
    require: 'ngModel'
    priority: 1

    link: (scope, elem, attrs, ngModel) ->
      if elem[0].nodeName == 'SELECT'
        elem.off('change')

      value = attrs.selectize

      options =
        diacritics: true
        highlight: true
        openOnFocus: false
        create: false
        persist: true
#        maxOptions: 1000
        hideSelected: false
        selectOnTab: false
#        maxItems: null
        valueField: 'value'
        labelField: 'label'
        searchField: ['label']
        sortField: 'label'
#        searchConjunction: 'and'
        preload: "focus"
        html: "'<div><span>' + item.label + '</span></div>'"
        options: []

        render:
          option: (item, escape) ->
            scope.item = item
            $parse(options.html)(scope)

        load: (query, callback) ->
          $.ajax(
            url: options.url + '?' + encodeURIComponent(query)
            type: 'GET'
            error: () ->
              callback()
            success: (res) ->
              if res and res.length and !res[0].value?
                res.shift()
              callback(res.map((v) -> return (if v.value then {label:v.value, value:v._id} else {label:'', value:''})))
          )

      if value.indexOf(':') != -1
        if !value.startsWith('{')
          value = '{' + value + '}'
        v = scope.$eval('(' + value + ')')
        options = $.extend(options, v)

      if !options.url?
        delete options.load

      options.delimiter = (if options.delimiter? then options.delimiter else ',')

      if options.maxItems?
        options.plugins =
          'remove_button': {}
          'drag_drop': {}
#          'dropdown_header':
#            title: 'Header'
      else
        options.plugins =
          'restore_on_backspace': {}

      if attrs.placeholder?
        options.placeholder = attrs.placeholder

      selectize = elem.selectize(options)[0].selectize

      getValues = ->
        values = selectize.getValue()
        if !values
          values = []
        if type(values) is 'string'
          values = values.split(options.delimiter)
        return values

      selectize.on('change', ->
        $timeout(->
          v = getValues()

#          oo = []
#          for s in v
#            o = selectize.options[s]
#            console.log s, o
#            if o
#              oo.push(o)
#          console.log "change", oo, v, selectize.options

          ngModel.$setViewValue(v.join(options.delimiter))
          if v.length and scope._changeSelection
            scope._changeSelection(scope.$eval(attrs.field), v[0])
        )
      )

      if attrs.options
        newValues = attrs.options
        if newValues
          newValues = scope.$eval(newValues)

        values = newValues

        if values and type(values) is 'string'
          if values.indexOf(',')
            values = values.split(',')
          else if values.indexOf(';')
            values = values.split(';')
          else if values.indexOf('|')
            values = values.split('|')
          else if values.indexOf('\t')
            values = values.split('\t')
          else if values.indexOf('\n')
            values = values.split('\n')

        if values
          for i in [0..values.length - 1]
            if values[i]? and !values[i].label and !values[i].value
              values[i] = { value: values[i], label: values[i] }

        selectize.clearOptions()
        for option in values
          selectize.addOption(option)

        selectize.setValue(getValues())

      if attrs.disabled
        attrs.$observe('disabled', ->
          selectize.disabled = (if attrs.disabled? then attrs.disabled else false)
        )

#      scope.$watch('$select.selected', (newValue) ->
#        console.log "$select.selected", @, newValue
#        if ngModel.$viewValue != newValue
#          ngModel.$setViewValue(newValue)
#      )

      ngModel.$render = ->
        newValue = (if ngModel.$modelValue then ngModel.$modelValue else [])
        if !angular.equals(newValue, getValues())
          selectize.setValue(newValue)
          selectize.refreshItems()

      ngModel.$parsers.push((value) ->
        return (if value then value.split(options.delimiter) else [])
      )

      ngModel.$formatters.push((values) ->
        if values?
          if type(values) is 'string'
            return values
          else if values instanceof Array
            return values.join(options.delimiter)
          else
            return ""
      )
])

#.directive('selectize', [
#  '$parse'
#  '$timeout'
#
#  ($parse, $timeout) ->
#
#    restrict: 'A'
#    require: ['?ngModel']
#    priority: 1
#    scope:
#      options: '=',
#      placeholder: '@'
#
#    link: (scope, el, attrs, ctrls) ->
#
#      modelCtrl = ctrls[0]
#
#      scope.selected = null
#
#      $select = el.selectize(
#        valueField: 'value'
#        labelField: 'label'
#        searchField: 'label'
#        plugins: ['remove_button']
#        hideSelected: true
#
#        create: (input, cb) ->
#          cb({ name: input })
#
#        onChange: (val) ->
#          scope.$apply(->
#            scope.selected = _.map(val.split(','), (tag) ->
#              return {_id: 1, name: tag}
#            )
#        )
#
#        modelCtrl.$setViewValue(scope.selected)
#      )
#
#      scope.selectize = $select[0].selectize
#
#      scope.$watchCollection('options', (newTags, oldTags) ->
#        _.each(newTags, (tag) ->
#          selectize.addOption(tag)
#        )
#      )
#
#      scope.$watch(->
#        return modelCtrl.$viewValue
#      , (vals) ->
#        _.each(vals, (tag) ->
#          console.log('render', vals.length)
#          selectize.addItem(tag.name)
#        )
#      )
#
#])
