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

      config =
        delimiter: ','
        diacritics: true
        highlight: true
        openOnFocus: false
        create: false
        createOnBlur: false
        persist: true
        allowEmptyOption: false
#        maxOptions: 1000
        hideSelected: false
        selectOnTab: false
#        maxItems: null
        valueField: 'value'
        labelField: 'name'
        searchField: ['name']
        sortField: 'name'
#        searchConjunction: 'and'
        preload: true
        html: "'<div><span>' + item.name + '</span></div>'"
        options: []

        render:
          option: (item, escape) ->
            scope.item = item
            $parse(config.html)(scope)

        load: (query, callback) ->
          $.ajax(
            url: config.url + '?' + encodeURIComponent(query)
            type: 'GET'
            error: () ->
              callback()
            success: (res) ->
              if res and res.length and !res[0][config.valueField]?
                res.shift()
              callback(res.map((v) -> makeOption(v)))
          )

      v = scope.$eval(attrs.selectize)
      if type(v) is 'array'
        for e in v
          if e
            _.extend(config, e)
      else
        _.extend(config, v)

      #      console.log 'v:', v, 'config:', config

      if !config.url?
        delete config.load

      #      config.delimiter = (if config.delimiter? then config.delimiter else ',')
      #
      if config.maxItems?
        config.plugins =
          'remove_button': {}
          'drag_drop': {}
#          'dropdown_header':
#            title: 'Header'
      else
        config.plugins =
          'restore_on_backspace': {}

      if attrs.placeholder?
        config.placeholder = attrs.placeholder

      selectize = elem.selectize(config)[0].selectize

      makeOption = (v) ->
        lf = config.labelField
        vf = config.valueField
        o = {}
        if v
          if type(v) is 'object' and v[lf] and v[vf]
            o[lf] = v[lf]
            o[vf] = v[vf]
          else
            o[lf] = v
            o[vf] = v
        else
          o[lf] = ''
          o[vf] = ''
        return o

      getValues = ->
        values = selectize.getValue()
        if !values
          values = []
        if type(values) is 'string'
          values = values.split(config.delimiter)
        return values

      selectize.on('change', ->
        that = @

        $timeout(->
          v = getValues()

          #          oo = []
          #          for s in v
          #            o = selectize.options[s]
          #            console.log s, o
          #            if o
          #              oo.push(o)
          #          console.log "change", oo, v, selectize.options

          ngModel.$setViewValue(v.join(config.delimiter))

          if attrs.ngChange?
            scope.$eval(attrs.ngChange).apply(scope, [selectize])
#          if v.length and scope._changeSelection
#            scope._changeSelection(scope.$eval(attrs.field), v[0])
        )
      )

      if attrs.options
        options = scope.$eval(attrs.options)

        if options and type(options) is 'string'
          if options.indexOf(',')
            options = options.split(',')
          else if options.indexOf(';')
            options = options.split(';')
          else if options.indexOf('|')
            options = options.split('|')
          else if options.indexOf('\t')
            options = options.split('\t')
          else if options.indexOf('\n')
            options = options.split('\n')

        selectize.clearOptions()
        if options
          for i in [0..options.length - 1]
            selectize.addOption(makeOption(options[i]))
        selectize.refreshOptions(false)

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
          if config.create
            if type(newValue) is 'array'
              for v in newValue
                if selectize.getOption(v).length == 0
                  selectize.addOption(makeOption(v))
            else if selectize.getOption(newValue).length == 0
              selectize.addOption(makeOption(newValue))
          selectize.refreshOptions(false)
          selectize.setOptionsValue(newValue)
          selectize.refreshItems()

      if config.maxItems?
        ngModel.$parsers.push((value) ->
          return (if value then value.split(config.delimiter) else [])
        )

        ngModel.$formatters.push((values) ->
          if values?
            if type(values) is 'string'
              return values
            else if values instanceof Array
              return values.join(config.delimiter)
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
