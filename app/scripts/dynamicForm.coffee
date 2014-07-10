'use strict';

angular.module('dynamicForm', ['app', 'ui.bootstrap.modal', 'numberAttributes', 'dateAttributes', 'layoutAttributes', 'stringAttributes'])

.run( ->
  window.maskOptions =
    clearIfNotMatch: true
    translation:
      '0': {pattern: /\d/}
      '9': {pattern: /\d/, optional: true}
      '#': {pattern: /\d/, recursive: true}
      'A': {pattern: /[a-zA-Z0-9]/}
      'S': {pattern: /[a-zA-Z]/}
      'H': {pattern: /[A-Fa-f0-9]/}
      '~': {pattern: /[+-]/}
)

.factory('dynForm', [
  '$compile'
  '$http'
  '$templateCache'
  '$injector'
  '$timeout'
  '_'

  ($compile, $http, $templateCache, $injector, $timeout, _) ->

    build: (scope, formDefinition, model, selector, cb) ->
#      dom =
#        $('<div>').attr('ng-repeat', 't in tests')
#          .append($('<span>').addClass('btn btn-primary').text('{{t.id}}, {{t.created_at}}'))
#          .append($('<hr>'))

      @populateScopeForm(scope, formDefinition, model)

#      for field in scope.form.fields
#        @populateField(scope.form, field)

      that = @
      require(['dynFormTemplates'], (dft) ->

        generate = (form) ->
          formTmpl = if form.layout and form.layout.type then form.layout.type else 'form'

          template = ""
          if dft[formTmpl]
            template += dft[formTmpl]

          dynForm = $injector.get('dynForm')

          r = ""
          if dft['row_{0}'.format(formTmpl)]
            r += dft['row_{0}'.format(formTmpl)]
          else if dft['row']
            r += dft['row']

          l = ""
          if dft['label_{0}'.format(formTmpl)]
            l += dft['label_{0}'.format(formTmpl)]
          else if dft['label']
            l += dft['label']

          f = ""
          if dft['field_{0}'.format(formTmpl)]
            f += dft['field_{0}'.format(formTmpl)]
          else if dft['field']
            f += dft['field']

          prevCol = null

          fieldsTemplate = ""
          if form.fields.length > 0
            for fieldIndex in [0..form.fields.length - 1]
              field = dynForm.populateField(form, form.fields[fieldIndex])

              if field.column? or field.column_xs? or field.column_sm? or field.column_md? or field.column_lg?
                if prevCol
                  fieldsTemplate += '</div>\n</div>\n'
                fieldsTemplate += '<div class="col ' + field.getColClass() + '">\n<div class="column-back">\n'
                prevCol = field

              if field.type == 'subform'
                t = f
                subform = dynForm.populateForm(field.subform)
                field.subform = subform
                t = t.replace(/\<\!-- \<input\>--\>/g, generate(subform) + '\n')

              else
                t = ""
                if field.autolabel
                  t += l
                t += f
                fieldTmpl = if field.type then field.type else (if form.layout.type == 'display' then 'label' else 'input')
                i = ""
                if dft[fieldTmpl]
                  i += dft[fieldTmpl]
                if i.length
                  t = t.replace(/\<\!-- \<input\>--\>/g, i + '\n')

              rr = r
              if !field.autolabel and !field.break
                rr = '<div ng-controller="dynFormObjectCtrl">\n<!-- <fields>-->\n</div>'
              t = t.replace(/fieldIndex/g, fieldIndex.toString())
              fieldsTemplate += rr.replace(/\<\!-- \<fields\>--\>/g, t + '\n')

            if prevCol
              fieldsTemplate += '</div>\n</div>\n'

          return template.replace(/\<\!-- \<row\>--\>/g, fieldsTemplate)

        template = generate(scope.form)

        $timeout( ->
          element = angular.element(selector)
          if element.length
            dom = angular.element(template)
            element.append(dom)
            $compile(dom)(scope)

          cb(template) if cb
        , 100)
      )

    populateForm: (form) ->
      form = _.clone(form, true)
      form.model = null

      navButtons1 = [
        icon: 'double-angle-left'
        url: ''
      ,
        icon: 'angle-left'
        url: ''
      ]

      navButtons2 = [
        icon: 'angle-right'
        url: ''
      ,
        icon: 'double-angle-right'
        url: ''
      ]

      nav = false
      fb = []
      if form.buttons
        for b in form.buttons
          if typeof b is 'string'
            if b.toLowerCase() == 'nav'
              nav = true
            if b.toLowerCase() == 'edit'
              fb.push({ icon: 'pencil', url: 'edit' })
            else if b.toLowerCase() == 'add'
              fb.push({ icon: 'plus32', url: 'add' })
            else if b.toLowerCase() == 'delete'
              fb.push({ icon: 'trash3', url: 'delete' })
          else
            fb.push(b)
      form.buttons = fb
      if nav
        form.buttons = navButtons1.concat(form.buttons).concat(navButtons2)

      if form.layout.type != 'display'
        if form.editMode == undefined
          form.editMode = 'always'
        if form.canEdit == undefined
          form.canEdit = true
        if form.canInsert == undefined
          form.canInsert = true
        if form.canDelete == undefined
          form.canDelete = true
        if form.canMove == undefined
          form.canMove = true

      if form.autolabel == undefined
        form.autolabel = true

      form.getClass = () ->
        c = []
        if @layout.type == 'form'
          if @layout.style == 'horizontal'
            c.push('form-horizontal')
          else if @layout.style == 'vertical'
            c.push('form-vertical')
          else if @layout.style == 'inline'
            c.push('form-inline')
        return c.join(" ")

      form.domName = () ->
        return @name

      form.domId = () ->
        return @name + '_id'

      return form

    populateScopeForm: (scope, form, model) ->
      scope.form = @populateForm(form)
      scope.rows = null

      if model instanceof Array
        scope.rows = model
      else if model
        scope.form.model = model
        scope.rows = model.rows

      scope.form.rows = scope.rows

      scope.fields = scope.form.fields

    populateField: (form, field) ->
      if field.show == undefined
        field.show = true

      if field.autolabel == undefined
        field.autolabel = form.autolabel

      field.form = form

      field.domName = (type, idx) ->
        return @form.domName() + '_' + type + '_' + @fieldname + '_' + idx

      field.domId = (type, idx) ->
        return @form.domName() + '_' + type + '_' + @fieldname + '_' + idx + '_id'

      field.getLabelClass = () ->
        if @input?
          xs = @input
          sm = @input
          md = @input
          lg = @input

        else
          xs = 3
          sm = 3
          md = 3
          lg = 2

        if @input_xs?
          xs = @input_xs
        if @input_sm?
          sm = @input_sm
        if @input_md?
          md = @input_md
        if @input_lg?
          lg = @input_lg

        c = []
        c.push('col-xs-{0}'.format(xs)) if xs
        c.push('col-sm-{0}'.format(sm)) if sm
        c.push('col-md-{0}'.format(md)) if md
        c.push('col-lg-{0}'.format(lg)) if lg

        return c.join(' ')

      field.getInputClass = () ->
        if @input?
          xs = @input
          sm = @input
          md = @input
          lg = @input

        else if @type == 'subform' or !@autolabel
          xs = 12
          sm = 12
          md = 12
          lg = 12

        else
          xs = 0
          sm = 9
          md = 9
          lg = 10

        if @input_xs?
          xs = @input_xs
        if @input_sm?
          sm = @input_sm
        if @input_md?
          md = @input_md
        if @input_lg?
          lg = @input_lg

        c = []

        if @rowSize?
          c.push('row-{0}'.format(@rowSize))

        if @type == 'caption'
          c.push('text-center')

        c.push('col-xs-{0}'.format(xs)) if xs
        c.push('col-sm-{0}'.format(sm)) if sm
        c.push('col-md-{0}'.format(md)) if md
        c.push('col-lg-{0}'.format(lg)) if lg

        return c.join(' ')

      field.getColClass = () ->
        if @column?
          xs = @column
          sm = @column
          md = @column
          lg = @column

        else
          xs = 6
          sm = 6
          md = 6
          lg = 6

        if @column_xs?
          xs = @column_xs
        if @column_sm?
          sm = @column_sm
        if @column_md?
          md = @column_md
        if @column_lg?
          lg = @column_lg

        c = []
        c.push('col-xs-{0}'.format(xs)) if xs
        c.push('col-sm-{0}'.format(sm)) if sm
        c.push('col-md-{0}'.format(md)) if md
        c.push('col-lg-{0}'.format(lg)) if lg

        return c.join(' ')

      return field


    initScope: ($scope) ->
      $scope.fields = $scope.form.fields
      $scope.$errors = []
      $scope.editStates = {}
      $scope.origValues = null
      $scope.origIdx = -1

#      if !$scope.rows.scope and $scope.$parent and $scope.fi
#        p = $scope.$parent
#        if p.rows and p.$index and p.fields
#          p.rows[p.$index][p.fields[$scope.fi].fieldname].scope = $scope

      $scope.getClass = () ->
        @form.getClass()

      $scope.domName = () ->
        @form.domName()

      $scope.domId = () ->
        @form.domId()

      $scope.hasState = (state, idx) ->
        if @validRow(idx)
          return @editStates[idx + 1] and @editStates[idx + 1].indexOf(state) != -1
        else
          for e in @editStates
            if e and e.indexOf(state) != -1
              return true
          return false

      $scope.addState = (state, idx) ->
        if idx?
          _idx = idx + 1
        else
          _idx = 0
          idx = null
        if !@hasState(state, idx)
          if @editStates[_idx]
            @editStates[_idx] += state
          else
            @editStates[_idx] = state

      $scope.removeState = (state, idx) ->
        if idx?
          _idx = idx + 1
        else
          _idx = 0
          idx = null
        if @hasState(state, idx)
          @editStates[_idx] = @editStates[_idx].replace(state, '')


    initForm: ($scope) ->
      $scope._copyRow = (_source, _target) ->
        for f of _source
          if !f.startsWith('$')

            if angular.isArray(_source[f])
              _new = false
              if _target[f] and angular.isArray(_target[f])
                a = _target[f]
              else
                a = []
                _new = true
              for i in [0.._source[f].length - 1]
                if i < a.length and a[i] and angular.isObject(a[i]) and Object.keys(a[i]).length > 0
                  @_copyRow(_source[f][i], a[i])
                else
                  v = {}
                  @_copyRow(_source[f][i], v)
                  a.push(v)
              if _new
                _target[f] = a

            else if angular.isObject(_source[f]) and Object.keys(_source[f]).length > 0
              if _target[f] and angular.isObject(_target[f]) and Object.keys(_target[f]).length > 0
                @_copyRow(_source[f], _target[f])
              else
                a = {}
                @_copyRow(_source[f], a)
                _target[f] = a

            else if _target[f] != _source[f]
              _target[f] = _source[f]

      $scope._isRowModified = (_source, _target) ->
        for f of _source
          if angular.isArray(_source[f])
            if _source[f].length != _target[f].length
              return false
            for i in [0.._source[f].length - 1]
              if @_isRowModified(_source[f][i], _target[f][i])
                return true
          else if angular.isObject(_source[f]) and Object.keys(_source[f]).length > 0
            if @_isRowModified(_source[f], _target[f])
              return true
          else
            return _source[f] != _target[f]

      $scope.validateAllFields = () ->
        if @hasOwnProperty('validateField')
          for i in [0..@rows.length - 1]
            for f in @fields
              @validateField(f, i)
        c = @$$childHead
        while c
          c.validateAllFields()
          c = c.$$nextSibling

  #      for i in [Math.max(0, _start)..Math.min(_end, rows.length - 1)]
  #        for f in fields
  #          r = rows[i][f.fieldname]
  #          if r
  #            console.log "_validateFields", f.fieldname, f.subform, r
  #            if angular.isArray(r) and f.subform and f.subform.fields
  #              @_validateFields(r, f.subform.fields, 0, r.length - 1)
  #            else if angular.isObject(r) and Object.keys(r).length > 0 and f.subform and f.subform.fields
  #              @_validateFields([r], f.subform.fields, 0, 0)
  #            else
  #              sc = findRowsInScope(rows, $rootScope)
  #              console.log sc, rows
  #              if sc
  #                sc.validateField(f, i)

      $scope.validRow = (idx) ->
        return idx != null and idx in [0..@rows.length - 1]

      $scope.edit = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx) and !@hasState('e', idx) and @canEdit(idx)
          @cancel()
          @origValues = null
          if @rows[idx]
            @origValues = {}
            @_copyRow(@rows[idx], @origValues)
  #          @origValues = JSON.stringify(@rows[idx])
            @origIdx = idx
            @addState('e', idx)
            console.log "edit", idx, @origValues, @rows

      $scope.insert = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx) and @form.canInsert
          @addState('i', idx)
          @edit(idx)

      $scope.delete = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx) and @form.canDelete
          @cancel()
          @addState('d', idx)

      $scope.moveup = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx)
          console.log ""

      $scope.movedown = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx)
          console.log ""

      $scope.save = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx)
          console.log "save", idx, @origValues, @rows
          @removeState('e', idx)
          if @origValues and @origIdx == idx
            if @_isRowModified(@origValues, @rows[idx])
              @addState('m', idx)
            if @form.model
              @form.model.update(@rows[idx])
            @origValues = null
            @origIdx = -1
            if @rows and @rows.length == 1
              @edit(0)

      $scope.cancel = (idx) ->
        if !@validRow(idx)
          return @cancelAll()
        else
          console.log "cancel", idx, @origValues, @rows
          @removeState('e', idx)
          if @rows and @origValues and @origIdx == idx
            @_copyRow(@origValues, @rows[idx])
  #          @rows[idx] = JSON.parse(@origValues)
            @validateAllFields()
            @origValues = null
            @origIdx = -1
            if @rows.length == 1
              @edit(0)

      $scope.cancelAll = () ->
        for i in [0..@rows.length - 1]
          @cancel(i)

      $scope.hasAction = () ->
        return @form.canEdit or @form.canInsert or @form.canDelete or @form.canMove

      $scope.canEdit = () ->
        return @form.canEdit

      $scope.isEditing = (idx) ->
        return @hasState('e', idx) or @form.editMode == 'always'

      $scope.isDeleted = (idx) ->
        return @hasState('d', idx)

      $scope.isInserted = (idx) ->
        return @hasState('i', idx)

      $scope.isModified = (idx) ->
        return @hasState('m', idx)

      $scope.removeErrors = (field, idx) ->
        if field? and typeof field is 'number' and idx == null
          idx = field
          field = null

        ee = _.clone(@$errors)
        for e in ee
          if (!field? or e.field == field.fieldname) and (idx == null or e.idx == idx)
            @$errors.splice(@$errors.indexOf(e), 1)

      $scope.hasErrors = (field, idx) ->
        return @errors(field, idx).length > 0

      $scope.addErrors = (err) ->
        if err
          for e in err
            @$errors.push(e)

      $scope.errors = (field, idx) ->
        if field? and typeof field is 'number' and idx == null
          idx = field
          field = null

        err = []
        for e in @$errors
          if (!field? or e.field == field.fieldname) and (idx == null or e.idx == idx)
            err.push(e)
        return err

      $scope.validate = (_start, _end, fields) ->
        scope = @
        require(['validator'], (validator) ->
          scope.removeErrors()
          for i in [Math.max(0, _start)..Math.min(_end, scope.rows.length - 1)]
            err = validator.validate(scope.rows, fields, i)
            if err and err.length
              scope.addErrors(err)
          scope.$apply()
          console.log "$scope.validate", err, scope.$errors
        )

      $scope.validateField = (field, idx) ->
        scope = @
        require(['validator'], (validator) ->
          scope.removeErrors(field, idx)
          err = _.clone(validator.validateField(scope.rows, field, idx))
          if err and err.length
            scope.addErrors(err)
          scope.$apply()
  #        console.log "$scope.validateField", field.fieldname, idx, err, scope.$errors
        )

      $scope.subformInit = () ->
        @form = @$parent.fields[@fi].subform
        @fields = @form.fields
        row = @$parent.rows[@$parent.$index]
        if row[@$parent.fields[@fi].fieldname]
          @rows = row[@$parent.fields[@fi].fieldname]
          if !angular.isArray(@rows)
            @rows = [@rows]

      $scope.submit = () ->
        @save()


    initTable: ($scope) ->
      $scope.perPage = 10
      $scope.filtersVisible = false
      $scope.filters = {}
      $scope.sort =
        sortingOrder : 'id'
        reverse : false

      $scope.filtersQuery = () ->
        w = []
        for k in Object.keys($scope.filters)
          if @filters[k].length
            v = @filters[k]
            op = '='

            if v.startsWith('>=')
              v = v.substr(2)
              op = '>='
            else if v.startsWith('<=')
              v = v.substr(2)
              op = '<='
            else if v.startsWith('<>')
              v = v.substr(2)
              op = '!='
            else if v.startsWith('!=')
              v = v.substr(2)
              op = '!='
            else if v.startsWith('<')
              v = v.substr(1)
              op = '<'
            else if v.startsWith('>')
              v = v.substr(1)
              op = '>'
            else if v.startsWith('%')
              v = v.substr(1)
              op = 'LIKE'

            if v.startsWith('#')
              v = "TIMESTAMP '{0}'".format(v.substr(1))
            else
              v = "'{0}'".format(v)

            w.push("{0} {1} {2}".format(k, op, v))

        if w.length
          return w.join(', AND ')
        else
          return null

      $scope.sortQuery = () ->
        return @sort.sortingOrder + ' ' + (if @sort.reverse then 'DESC' else 'ASC')

      $scope.perPageQuery = () ->
        return (if @perPage? then @perPage else 10)

      $scope.filtersChanged = () ->
        if @form.model
          @form.model.where = @filtersQuery()
        @cancel()
        @removeErrors()
        if @form.model
          sc = @
          while sc and !sc.hasOwnProperty('rows')
            sc = sc.$parent
          @form.model.fetch((results) ->
            sc.rows = results
          )

      $scope.sortChanged = () ->
        if @form.model
          @form.model.order = @sortQuery()
        @cancel()
        @removeErrors()
        if @form.model
          sc = @
          while sc and !sc.hasOwnProperty('rows')
            sc = sc.$parent
          @form.model.fetch((results) ->
            sc.rows = results
          )

      $scope.perPageChanged = () ->
        if @form.model
          @form.model.perPage = @perPageQuery()
        @cancel()
        @removeErrors()
        if @form.model
          sc = @
          while sc and !sc.hasOwnProperty('rows')
            sc = sc.$parent
          @form.model.fetch((results) ->
            sc.rows = results
          )

    initModal: ($scope) ->


    getFieldDOM: (element) ->
#      scope = element.scope()
#      if (scope.$parent.form? and scope.$parent.form.layout.type == 'display') or (scope.form? and scope.form.layout.type == 'display')
      e = element.find('input')
      if !e or e.length == 0
        e = element.find('span')
      return e

    modelSchema: (modelName, cb) ->
      $http.get('/api/{0}/schema'.format(modelName))
      .success((data, status) ->
        cb(data) if cb
      )
      .error((data, status) ->
        cb(null) if cb
      )

    quickForm: (name, layout, style, title, model, cb) ->

      invalidFields = ['created_at', 'updated_at', 'loginAttempts', 'lockUntil', 'path', '_w', 'parentId', 'owner_id']

      if !layout
        layout = 'form'
      if !style
        style = 'horizontal'
      if !name
        name = 'quickForm'

      formDefinition =
        label: title
        name: name
        layout: {type: layout, style: style}
        fields: []

      typeFromFieldname = (fn) ->
        fn = fn.toLowerCase()
        if fn.match(/email/i)
          return "email"
        else if fn.match(/tel|cell|^pager$|fax|^facsimile$/i)
          return "phone"
        else if fn.match(/postal/i)
          return "postal"
        else if fn.match(/zip/i)
          return "zipcode"
        else if !fn.match(/date/i) and fn.match(/time/i)
          return "time"
        else if fn.match(/date/i)
          return "datetime"
        else if fn.match(/price|cost|retail/i)
          return "money"
        else if fn.match(/password/i)
          return "password"
        else if fn.match(/url|web/i)
          return "url"
        else if fn.match(/user/i)
          return "username"
        else if fn.match(/city|town/i)
          return "city"
        else if fn.match(/country/i)
          return "country"
        else
          return null

      objectToType = (fn, t, o) ->
        t = t.toLowerCase()
        r = {type: "input"}
        if t is 'string' or t is 'objectid'
          r = {type: "input"}
        else if t is 'number'
          r = {type: "input", number: true}
        else if t is 'boolean'
          r = {type: "check", switch: true}
        else if t is 'date'
          r = {type: "input", date: true}
        else if t is 'object'
          if o
            if o instanceof Array
              r = {type: ""}
            else if o instanceof Date
              r = {type: "input", date: true}

        n = typeFromFieldname(fn)
        if n
          r[n] = true
        return r

      addField = (fd, layout, fn, p) ->

        if fn in invalidFields
          return

        if fn.indexOf('.') != -1
          fp = fn.split('.')
          ln = fp.pop()

          if ln in invalidFields
            return

          if !p.options or !p.options.inline
            cf = []
            ff = formDefinition
            for f in fp
              cf.push(f)
  #            cfn = cf.join('.')

              ok = false
              for fff in ff.fields
                if fff.type == 'subform' and fff.fieldname == f
                  ff = fff.subform
                  ok = true

              if !ok
                s =
                  label: cf.join(' ').humanize()
                  type: 'subform'
                  fieldname: f
                  subform:
                    label: cf.join(' ').humanize()
                    name: 'sub_' + cf.join('_')
                    layout: {type:'sub{0}'.format(layout), style: style}
                    fields: []
                ff.fields.push(s)
                ff = s.subform

            fd = ff
            fn = ln

        if p.schema
          s =
            label: label
            type: 'subform'
            fieldname: fn
            subform:
              label: label
              name: 'sub_' + fn.replace(/\./g, '_')
              layout: {type:'sub{0}'.format(layout), style: style}
              fields: []
          fd.fields.push(s)
          for fn of p.schema.paths
            addField(s.subform, layout, fn, p.schema.paths[fn])

        else

          def = null
          if p.options and p.options.default
            def = p.options.default

          label = null
          if p.options and p.options.label
            label = p.options.label
          else
            label = fn.humanize()

          _type = "string"
          if p.instance
            _type = p.instance.toLowerCase()
          _type = objectToType(fn, _type, p.object)

          options = null
          if p.options and p.options.enum
            i = 0
            options = []
            for e in p.options.enum
              if e.length
                options.push({value:i, label:e})

          ref = null
          multi = false
          if p.options and p.options.ref
            ref = p.options.ref
          else if p.options and p.options.type and p.options.type instanceof Array
            if p.options.type[0].ref
              multi = true
              ref = p.options.type[0].ref

          ff = {fieldname:fn, type: _type.type}
          if label
            ff.label = label
          if def
            ff.default = def
          if options
            ff.config = {}
            x = p.options.enum.indexOf('')
            if x != -1
              ff.config.allowClear = true
#            ff.config.display_pre = '<i>'
#            ff.config.display_post = '</i>'
            ff.options = options
            ff.type = "select"
          if ref
            ff.config =
              url: '/api/{0}?perPage=10'.format(ref.toLowerCase())
              field: '_id'
              displayField: 'name'
#              display_pre: '<i>'
#              display_post: '</i>'
              multiple: multi
#              minimumInputLength: 1
            ff.type = "select"

          for t of _type
            if t != 'type' and !ff['number']?
              ff[t] = _type[t]

          fd.fields.push(ff)


      if model and typeof model is 'string'
        @modelSchema(model, (fields) ->
          for fn of fields
            addField(formDefinition, layout, fn, fields[fn])

          cb(formDefinition) if cb
        )

      else if model
        r = null
        if model.rows and model.rows.length
          r = model.rows[0]
        else if model instanceof Array and model.length
          r = model[0]

        for fn of Object.keys(r)
          addField(formDefinition, layout, fn, {path: fn, instance: typeof r[fn], object: r[fn]})

        cb(formDefinition) if cb

])

.factory('dynModal', [
  'dynForm'
  '$modal'
  '$rootScope'

  (dynForm, $modal, $rootScope) ->

    showModal: (title, scope, template, cb) ->

      ModalInstanceCtrl = ($scope, $modalInstance) ->
        $scope.modalOk = () ->
          $modalInstance.close()

        $scope.modalCancel = () ->
          $modalInstance.dismiss()

      modalTemplate =
        '<div ng-controller="dynModalCtrl">' +
        '  <div class="modal-header">' +
        '    <button class="close" type="button" ng-click="modalCancel()">&times;</button>' +
        '    <h4 class="modal-title">' + title + '</h4>' +
        '  </div>' +
        '  <div class="modal-body">' +
        '    <!-- <template>-->' +
        '  </div>' +
        '  <div class="modal-footer">' +
        '    <input class="btn btn-default" type="button" ng-click="modalCancel()" value="Close"/>' +
        '  </div>'

#      console.log scope, modalTemplate, template
      modal = $modal.open(
        scope: scope
        template: modalTemplate.replace(/\<\!-- \<template\>--\>/g, template)
        controller: ModalInstanceCtrl
#          windowClass: ''
        size: 'lg'
        backdrop: 'static'
      )

      modal.result.then(
        () ->
          cb(true) if cb
          console.log "Modal closed"
      , () ->
          cb(false) if cb
          console.log "Modal dismissed"
      )

    showModalForm: (formDefinition, model, cb) ->

      ModalInstanceCtrl = ($scope, $modalInstance) ->
        $scope.modalOk = () ->
          $modalInstance.close()

        $scope.modalCancel = () ->
          $modalInstance.dismiss()

      scope = $rootScope.$new(true)
      dynForm.build(scope, formDefinition, model, null, (template) ->
#        console.log template
        modal = $modal.open(
          scope: scope
          template: template
          controller: ModalInstanceCtrl
#          windowClass: ''
          size: if formDefinition.size then formDefinition.size else 'md'
          backdrop: 'static'
        )

        modal.result.then(
          () ->
            cb(true) if cb
            console.log "Modal closed"
        , () ->
            cb(false) if cb
            console.log "Modal dismissed"
        )
      )

    inputModal: (title, caption, cb) ->
      model = [{answer: ''}]
      formDefinition =
        label: title
        name: "modalForm"
        size: 'md'
        layout: {type: 'modal', style: 'horizontal'}
        buttons: ['OK', 'Cancel']

        fields: [
          label: caption
          type: "input"
          fieldname: 'answer'
        ]

      @showModalForm(formDefinition, model, (ok) ->
        if ok
          cb(model.answer) if cb
        else
          cb(null) if cb
      )

    yesNoModal: (title, caption, cb) ->
      model = [{}]
      formDefinition =
        label: title
        name: "modalForm"
        size: 'md'
        layout: {type: 'modal', style: 'horizontal'}
        buttons: ['YES', 'NO']
        autolabel: false

        fields: [
          col: 2
          type: "icon"
          value: "question22"
          fontsize: 40
          shadow: 2
          vcenter: true
        ,
          col: 10
          type: "caption"
          value: caption
          fontsize: 16
          vcenter: true
        ]

      @showModalForm(formDefinition, model, (ok) ->
        cb(ok) if cb
      )

    alert: (caption, cb) ->
      model = [{}]
      formDefinition =
        label: "Alert"
        name: "modalForm"
        size: 'sm'
        layout: {type: 'modal', style: 'horizontal'}
        buttons: ['OK']
        autolabel: false

        fields: [
          col: 2
          rowSize: 'sm'
          type: "icon"
          value: "exclamation2"
          fontsize: 40
          vcenter: true
          shadow: 2
        ,
          col: 10
          rowSize: 'sm'
          type: "caption"
          value: caption
          fontsize: 16
          vcenter: true
#          shadow: 1
          bold: true
        ]

      @showModalForm(formDefinition, model, () ->
        cb() if cb
      )

    info: (caption, cb) ->
      model = [{}]
      formDefinition =
        label: "Information"
        name: "modalForm"
        size: 'sm'
        layout: {type: 'modal', style: 'horizontal'}
        buttons: ['OK']
        autolabel: false

        fields: [
          col: 2
          rowSize: 'sm'
          type: "icon"
          value: "info6"
          fontsize: 40
          shadow: 2
        ,
          col: 10
          rowSize: 'sm'
          type: "caption"
          value: caption
          fontsize: 16
#          shadow: 1
          bold: true
        ]

      @showModalForm(formDefinition, model, () ->
        cb() if cb
      )

    chooseModal: (title, caption, items, cb) ->
      model = [{}]
      formDefinition =
        label: title
        name: "modalForm"
        size: 'md'
        layout: {type: 'modal', style: 'horizontal'}
        buttons: ['OK', 'Cancel']
        autolabel: false

        fields: [
          type: "caption"
          value: caption
          style: {name: 'font-size', value: '16px'}
        ,
          type: "checklistbox"
          options: items
          fieldname: 'items'
        ]

      @showModalForm(formDefinition, model, (ok) ->
        cb(ok) if cb
      )

])

.controller('dynFormCtrl', [
  '$scope'
  'Globals'
  'dynForm'

  ($scope, globals, dynForm) ->
    dynForm.initScope($scope)
    dynForm.initForm($scope)

    if $scope.rows and $scope.rows.length == 1
      $scope.edit(0)
])

.controller('dynTableCtrl', [
  '$scope'
  'Globals'
  'dynForm'

  ($scope, globals, dynForm) ->
    dynForm.initScope($scope)
    dynForm.initForm($scope)
    dynForm.initTable($scope)
])

.controller('dynModalCtrl', [
  '$scope'
  'Globals'
  'dynForm'

  ($scope, globals, dynForm) ->
    dynForm.initScope($scope)
    dynForm.initForm($scope)
    dynForm.initModal($scope)
])

.controller('dynFormObjectCtrl', [
  '$scope'
  'Globals'
  'dynForm'

  ($scope, globals, dynForm) ->

    $scope.check = (item) ->
      item.checked = !item.checked
#      console.log "check()", item.checked

#    $scope.$on('updateInput', ->
#      f = $scope.f
#      f.input = _.cloneDeep(f.row[f.field.model])
#    )
#
#    $scope.$watch('f.input', (newValue, oldValue) ->
#      if (oldValue or newValue) and (oldValue != newValue)
#        f = $scope.f
#        console.log "watch-input", newValue, f.field
#        f.rows._noupdate = true
#        f.row[f.field.fieldname] = newValue
#        f.form._modified = true
#        $scope.$parent.$broadcast 'updateInput'
#    , yes)
])

.directive('dynId', [
  '$interpolate'
  '$compile'

  ($interpolate, $compile) ->
    restrict: 'A'
#    terminal: true
    priority: 100000

    link: (scope, element) ->
      name = $interpolate(element.attr('dyn-id'))(scope);
      element.removeAttr('dyn-id');
      element.attr('id', name);
      $compile(element)(scope);
])

.directive('dynText', [
  '$compile'
  '$interpolate'

  ($compile, $interpolate) ->
    restrict: 'A'
#    terminal: true
    priority: 1000

    link: (scope, element, attrs) ->
      name = $interpolate(element.attr('dyn-value'))(scope)
      element.removeAttr('dyn-value')
      element.text('{{' + name + '}}')
      $compile(element)(scope)
])

.directive('dynValue', [
  '$compile'
  '$interpolate'

  ($compile, $interpolate) ->
    restrict: 'A'
#    terminal: true
    priority: 1000

    link: (scope, element, attrs) ->
      name = $interpolate(element.attr('dyn-value'))(scope)
      element.removeAttr('dyn-value')
      element.val('{{' + name + '}}')
      $compile(element)(scope)
])

.directive('attributes', [
  'attributes'
  '$parse'

  (attributes, $parse) ->
    restrict: 'A'

    link: (scope, element, attrs) ->
      field = $parse(attrs.attributes)(scope)
      for k in Object.keys(field)
        k = k.toLowerCase()
        if k != "label" and k != "type" and k != "description" and k != "fieldname" and k != "options" and k != "dompath" and k != "show" and k[0] != "_" and k != "value"
          attributes.process(scope, element, k, field)
])

.factory('attributes', [
  '$compile'
  'dynForm'
  'numberAttributes'
  'dateAttributes'
  'layoutAttributes'
  'stringAttributes'

  ($compile, dynForm, numbers, dates, layouts, strings) ->
    data =
      store:

        type:
          type: 'type'
          code: (scope, element, field) ->
            if ['number', 'text', 'textarea'].indexOf(field.type) != -1
              element.find('input').attr('type', field.type)

        style:
          type: 'css'
          code: (scope, element, field) ->
            e = dynForm.getFieldDOM(element)
            e.css(field.style.name, field.style.value)

      process: (scope, element, name, field) ->
        s = @store[name]
        if s
          s.code(scope, element, field)
        return s

    data.store = angular.extend(data.store, numbers, dates, layouts, strings)

    return data
])


#.config(($provide) ->
#  $provide.decorator('ngModelDirective', ($delegate) ->
#    ngModel = $delegate[0]
#    controller = ngModel.controller
#    ngModel.controller = ['$scope', '$element', '$attrs', '$injector', (scope, element, attrs, $injector) ->
#      $interpolate = $injector.get('$interpolate')
#      attrs.$set('name', $interpolate(attrs.name || '')(scope))
#      $injector.invoke(controller, this, {
#        '$scope': scope
#        '$element': element
#        '$attrs': attrs
#      })
#    ]
#    $delegate
#  )
#
#  $provide.decorator('formDirective', ($delegate) ->
#    form = $delegate[0]
#    controller = form.controller
#    form.controller = ['$scope', '$element', '$attrs', '$injector', (scope, element, attrs, $injector) ->
#      $interpolate = $injector.get('$interpolate')
#      attrs.$set('name', $interpolate(attrs.name || attrs.ngForm || '')(scope))
#      $injector.invoke(controller, this, {
#        '$scope': scope
#        '$element': element
#        '$attrs': attrs
#      })
#    ]
#    $delegate
#  )
#)

.directive("customSort", [

  () ->
    restrict: 'A'

    transclude: true

    scope:
      order: '='
      sort: '='

    template:
      '<a ng-click="sort_by(order)" style="color: #555555;">' +
      '  <span ng-transclude></span>' +
      '  <i ng-class="selectedCls(order)"></i>' +
      '</a>'

    link: (scope) ->
      scope.sort_by = (newSortingOrder) ->
        sort = scope.$parent.sort
        if sort.sortingOrder == newSortingOrder
          sort.reverse = !sort.reverse
        sort.sortingOrder = newSortingOrder
        scope.$parent.sortChanged()

      scope.selectedCls = (column) ->
        if column == scope.$parent.sort.sortingOrder
          return 'fa fa-sort-' + (if scope.sort.reverse then 'desc' else 'asc')
        else
          return 'fa fa-sort'
])
