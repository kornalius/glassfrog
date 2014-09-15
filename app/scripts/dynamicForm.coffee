'use strict';

angular.module('dynamicForm', ['app', 'ui.bootstrap.modal', 'template/modal/backdrop.html', 'template/modal/window.html', 'numberAttributes', 'dateAttributes', 'layoutAttributes', 'stringAttributes', 'iconspickerAttributes', 'restangular'])

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
  'Restangular'

  ($compile, $http, $templateCache, $injector, $timeout, _, Restangular) ->

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

        prevCol = null
        dynForm = $injector.get('dynForm')

        generateFields = (form, layout, fields) ->
          formTmpl = if layout and layout.type then layout.type else 'form'

          r = ""
          if dft['row_{0}'.format(formTmpl)]
            r = dft['row_{0}'.format(formTmpl)]
          else if dft['row']
            r = dft['row']

          l = ""
          if dft['label_{0}'.format(formTmpl)]
            l = dft['label_{0}'.format(formTmpl)]
          else if dft['label']
            l = dft['label']

          f = ""
          if dft['field_{0}'.format(formTmpl)]
            f = dft['field_{0}'.format(formTmpl)]
          else if dft['field']
            f = dft['field']

#          console.log "generateFields()", "form:", form, "\n", "layout:", layout, "\n", "fields:", fields, "\n", "formTmpl:", formTmpl, "\n", "r:", r, "\n", "l:", l, "\n", "f:", f

          fieldsTemplate = ""
          if fields.length > 0
            for fieldIndex in [0..fields.length - 1]
              field = dynForm.populateField(form, fields[fieldIndex])

              field.index = fieldIndex

              if field.fields?
                ocol = prevCol
                prevCol = null
                subform = dynForm.populateForm(form)
                subform.fields = field.fields
#                field.subform = subform
                ff = generateFields(subform, { type: 'subfield', style: layout.style }, field.fields)
                t = f.replace(/\<\!-- \<input\>--\>/g, ff + '\n')
                prevCol = ocol

              else
                if field.column? or field.column_xs? or field.column_sm? or field.column_md? or field.column_lg?
                  if prevCol
                    fieldsTemplate += '</div>\n</div>\n'
                  fieldsTemplate += '<div class="col ' + field.getColClass() + '">\n<div class="column-back">\n'
                  prevCol = field

                if field.type == 'subform'
                  subform = dynForm.populateForm(field.subform)
                  field.subform = subform
                  t = f.replace(/\<\!-- \<input\>--\>/g, generate(subform) + '\n')

                else
                  t = ""
                  if field.autolabel or layout.type == 'display'
                    t += l
                  t += f
                  fieldTmpl = if field.type then field.type else (if layout.type == 'display' then 'label' else 'input')

                  i = ""

                  if !field.inputHidden?
                    if field.type == 'include'
                      i = '<ng-include src="\'' + field.template + '\'">'

                    else if dft[fieldTmpl]
                      i += dft[fieldTmpl]

                  if i.length
                    t = t.replace(/\<\!-- \<input\>--\>/g, i + '\n')

              rr = r
              if !field.autolabel and !field.break and !field.fields
                rr = '<div ng-controller="dynFormObjectCtrl">\n<!-- <fields>-->\n</div>'
              rr = rr.replace(/\{\%fieldIndex\%\}/g, fieldIndex.toString()).replace(/\{\%fieldName\%\}/g, (if field.fieldname? then field.fieldname else ''))
              t = t.replace(/\{\%fieldIndex\%\}/g, fieldIndex.toString()).replace(/\{\%fieldName\%\}/g, (if field.fieldname? then field.fieldname else ''))
              fieldsTemplate += rr.replace(/\<\!-- \<fields\>--\>/g, t + '\n')

            if prevCol
              fieldsTemplate += '</div>\n</div>\n'

          return fieldsTemplate

        generate = (form) ->
          ocol = prevCol
          prevCol = null

          formTmpl = if form.layout and form.layout.type then form.layout.type else 'form'

          template = ""
          if dft[formTmpl]
            template += dft[formTmpl]

          fieldsTemplate = generateFields(form, form.layout, form.fields)

          prevCol = ocol

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
      form = _.cloneDeep(form)
      form.model = null
      form.activeTab = 0
      form.$errors = []

      navButtons1 = [
        icon: 'cic-double-angle-left'
        url: ''
      ,
        icon: 'cic-angle-left'
        url: ''
      ]

      navButtons2 = [
        icon: 'cic-angle-right'
        url: ''
      ,
        icon: 'cic-double-angle-right'
        url: ''
      ]

      nav = false
      fb = []
      if form.buttons
        for b in form.buttons
          if typeof b is 'string' and form.layout.type != 'modal'
            if b.toLowerCase() == 'nav'
              nav = true
            if b.toLowerCase() == 'edit'
              fb.push({ icon: 'cic-pencil', url: 'edit' })
            else if b.toLowerCase() == 'save'
              fb.push({ icon: 'cic-disk3', url: 'save' })
            else if b.toLowerCase() == 'cancel'
              fb.push({ icon: 'cic-close', url: 'cancel' })
            else if b.toLowerCase() == 'add'
              fb.push({ icon: 'cic-plus32', url: 'add' })
            else if b.toLowerCase() == 'delete'
              fb.push({ icon: 'cic-trash3', url: 'delete' })
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
        if form.canAppend == undefined
          form.canAppend = true
        if form.canDelete == undefined
          form.canDelete = true
        if form.canMove == undefined
          form.canMove = true

      if form.autolabel == undefined
        form.autolabel = true

      form.on = (name, args...) ->
        if @events and @events[name]
          return @events[name].call(@, args)
        else
          return null

      form.getClass = () ->
        c = []
        if @layout.type == 'form' or @layout.type == 'modal`'
          if @layout.style == 'horizontal'
            c.push('form-horizontal')
          else if @layout.style == 'vertical'
            c.push('form-vertical')
          else if @layout.style == 'inline'
            c.push('form-inline')
        else if @layout.type == 'table'
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

      if field.tab == undefined
        field.tab = 0

      if field.autolabel and field.label == undefined
        field.label = _.str.humanize(field.fieldname)

      field.form = form

      field.domName = (type, idx) ->
        return @form.domName() + '_' + type + '_' + (if @fieldname? then @fieldname.replace(/\./g, '_') else '') + '_' + idx

      field.domId = (type, idx) ->
        return @form.domName() + '_' + type + '_' +(if @fieldname? then @fieldname.replace(/\./g, '_') else '') + '_' + idx + '_id'

      field.getLabelClass = () ->
        if @input?
          xs = @input
          sm = @input
          md = @input
          lg = @input

        else if @form.layout.type == 'display'
          xs = 0
          sm = 0
          md = 0
          lg = 0

        else
          xs = 9
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
        c.push('col-xs-{0}'.format(12 - xs)) if xs
        c.push('col-sm-{0}'.format(12 - sm)) if sm
        c.push('col-md-{0}'.format(12 - md)) if md
        c.push('col-lg-{0}'.format(12 - lg)) if lg

        return c.join(' ')

      field.getInputClass = () ->
        if @input?
          xs = @input
          sm = @input
          md = @input
          lg = @input

        else if @type == 'subform' or @type == 'tabs' or !@autolabel
          xs = 12
          sm = 12
          md = 12
          lg = 12

        else if @fields?
          xs = 12
          sm = 12
          md = 12
          lg = 12

        else if @form.layout.type == 'display'
          xs = 0
          sm = 0
          md = 0
          lg = 0

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
      $scope.editStates = {}
      $scope.origValues = null
      $scope.orig = null
      $scope.origIdx = -1

      require(['validator'], (validator) ->
        $scope.validator = validator
      )

      $scope.countries = countries
      $scope.country_states = states
      $scope.current_states = ""

      $scope._changeSelection = (field, val) ->
        if field.type.toLowerCase() == 'country'
          idx = @countries.indexOf(val)
          if idx != -1
            a = @country_states[idx]
            if type(a) is 'string'
              a = a.split('|')
              elem = angular.element('#country_states')
              if elem.length
                selectize = elem.selectize()[0].selectize
                values = a

                if values and values.length and !values[0].label and !values[0].value
                  for i in [0..values.length - 1]
                    values[i] = { value: values[i], label: values[i] }

                selectize.clearOptions()
                angular.forEach(values, (option) ->
                  selectize.addOption(option)
                )

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
        if idx != null
          _idx = idx + 1
        else
          _idx = 0
          idx = null
        if @hasState(state, idx)
          @editStates[_idx] = @editStates[_idx].replace(state, '')


    initForm: ($scope) ->

      makeKey = (lhs, rhs) ->
        if !lhs? or lhs.length == 0
          return rhs
        else
          if !rhs.startsWith('[')
            return lhs + '.' + rhs
          else
            return lhs + rhs

      $scope._flatten = (key, _source, complex) ->
        r = []

        if angular.isArray(_source)
          if _source.length
            for i in [0.._source.length - 1]
              r = r.concat(r, @_flatten(makeKey(key, '[' + i.toString() + ']'), _source[i], complex))

        else if angular.isObject(_source) and Object.keys(_source).length
          for k of _source
            r = r.concat(@_flatten(makeKey(key, k), _source[k], complex))

        else
          if complex
            e = {}
            e[key] = _source
            r.push(e)
          else
            r.push(_source)

        return r

      $scope._diff = (_source, _target) ->
        src = JSON.stringify(@_flatten('', _source, false))
        tgt = JSON.stringify(@_flatten('', _target, false))
        return JsDiff.diffChars(src, tgt)

      $scope._isRowModified = (_source, _target) ->
        src = JSON.stringify(@_flatten('', _source, false))
        tgt = JSON.stringify(@_flatten('', _target, false))
        return src != tgt

      $scope.validRow = (idx) ->
        return idx != null and @rows and idx in [0..@rows.length - 1]

      $scope.edit = (idx, forceInline) ->
        idx = if idx != null then idx else 0
        if @validRow(idx) and !@hasState('e', idx) and @canEdit(idx)
          that = @
          @cancel()
          @origValues = null
          @orig = null
          @origIdx = -1
          @origValues = _.cloneDeep(@rows[idx].plain())
          @orig = angular.copy(@rows[idx])
          @origIdx = idx
          @addState('e', idx)
          console.log "edit", idx, @origValues, @orig, @rows

          if !forceInline? and @form.editModal?
            that.form.modalEditing = true
            $injector.get('dynModal').showModalForm(that.form.editModal, [@rows[idx]], (mr) ->
              if mr
                that.save(idx)
              else
                that.cancel(idx)
            )

#          $timeout(->
#            if that.validateAllFields?
#              that.validateAllFields()
#          , 10)

      $scope.insert = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx) and @form.canInsert
          if @form.model
            that = @
            @form.model.create({}, that.form.blank, (r) ->
              if r and that.form.model.rows.push?
                that.form.model.rows.push(r)
                idx = that.form.model.rows.length - 1
                that.addState('i', idx)
                console.log "insert", idx, r, that.rows
                that.edit(idx)
            )

      $scope.append = () ->
        if @form.canAppend
          if @form.model
            that = @
            @form.model.create({}, that.form.blank, (r) ->
              if r and that.form.model.rows.push?
                that.form.model.rows.push(r)
                idx = that.form.model.rows.length - 1
                that.addState('a', idx)
                console.log "append", idx, r, that.rows
                that.edit(idx)
            )

      $scope.delete = (idx) ->
        idx = if idx != null then idx else 0
        if @validRow(idx) and @form.canDelete
          @form.on('delete', @rows[idx])
          @cancel(idx)
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
        that = @
        console.log "save", idx, @origValues, @orig, @rows
        idx = if idx != null then idx else 0
        if @validRow(idx)
          @validateAllFields()
          if !@hasErrors(idx)
            @form.modalEditing = false
            @removeState('e', idx)
            if @orig and @origValues and @origIdx == idx
              if @isModified(idx)
                @addState('m', idx)
              if @form.model
                @form.model.update(@rows[idx], (result) ->
                  that.origValues = null
                  that.orig = null
                  that.origIdx = -1
                  that.form.on('save', result)
                  if (that.rows and that.rows.length == 1) or that.form.editMode == 'always'
                    if that.form.blank
                      that.form.model.createTemp({}, true, (d) ->
                        that.rows = that.form.model.rows
                        that.edit(0)
                      )
                    else
                      that.edit(0)
                )

      $scope._cancelled = (idx) ->
        if @rows and @rows[idx]?
          console.log "_cancelled", @orig, @rows[idx]

          angular.copy(@orig, @rows[idx])

          s = $scope
          f = s[s.domName()]
          while !f or !f.$setPristine
            s = s.$parent
            if !s or !s.domName
              break
            f = s[s.domName()]

          if f and f.$setPristine
            f.$setPristine()

          @origValues = null
          @orig = null
          @origIdx = -1
          @form.on('cancel')

          if @rows.length == 1 or @form.editMode == 'always'
            if @form.blank
              that = @
              @form.model.createTemp({}, true, (d) ->
                that.rows = that.form.model.rows
                that.edit(0)
              )
            else
              @edit(0)

#          that = @
#          @rows[idx]._id = @orig._id
#          @rows[idx].get().then((result) ->
#            that.rows[idx] = angular.copy(result)
#            console.log "get()", result, that.rows[idx]
#            that.origValues = null
#            that.orig = null
#            that.origIdx = -1
#            that.form.on('cancel')
#
#            if that.rows.length == 1 or that.form.editMode == 'always'
#              that.edit(0)
#          )
        else
          @origValues = null
          @orig = null
          @origIdx = -1
          @form.on('cancel')

          if @rows.length == 1 or @form.editMode == 'always'
            @edit(0)

      $scope.cancel = (idx) ->
        that = @
        if !@validRow(idx)
          return @cancelAll()
        else
          @form.modalEditing = false
          @removeState('e', idx)
#          console.log "try cancel", idx, @origValues, @orig, @rows
          if @rows and @origIdx == idx and @origValues and @orig
            console.log "cancel", idx, @origValues, @orig, @rows
            if @isModified(idx)
              @addState('m', idx)
            if @isInserted(idx) or @isAppended(idx)
              if @form.model
                @form.model.delete(@rows[idx], (result) ->
                  that.form.on('cancel', result)
                  that._cancelled(idx)
                )
            else
              that._cancelled(idx)

      $scope.cancelAll = () ->
        for i in [0..@rows.length - 1]
          @cancel(i)

      $scope.hasAction = () ->
        return @form.canEdit or @form.canInsert or @form.canAppend or @form.canDelete or @form.canMove

      $scope.canEdit = () ->
        return @form.canEdit

      $scope.isEditing = (idx) ->
        return @hasState('e', idx) or @form.editMode == 'always'

      $scope.isDeleted = (idx) ->
        return @hasState('d', idx)

      $scope.isInserted = (idx) ->
        return @hasState('i', idx)

      $scope.isAppended = (idx) ->
        return @hasState('a', idx)

      $scope.isModified = (idx) ->
        if @isEditing(idx) and @origValues and @orig
          return @_isRowModified(@origValues, @rows[idx].plain())
        else
          return false

      $scope.removeErrors = (field, idx) ->
        if field? and type(field) is 'number' and !idx?
          idx = field
          field = null

        ee = _.clone(@form.$errors)
        for e in ee
          if (!field? or e.field == field.fieldname) and (!idx? or e.idx == idx)
            @form.$errors.splice(@form.$errors.indexOf(e), 1)

      $scope.hasErrors = (field, idx) ->
        return @errors(field, idx).length > 0

      $scope.addErrors = (err) ->
        @form.$errors = @form.$errors.concat(err)

      $scope.errors = (field, idx) ->
        if field? and type(field) is 'number' and !idx?
          idx = field
          field = null

        err = []
        for e in @form.$errors
          if (!field? or e.field == field.fieldname) and (!idx? or e.idx == idx)
            err.push(e)

        return err

      $scope.validateAllFields = () ->
        if @hasOwnProperty('validateField')
          for i in [0..@rows.length - 1]
            for f in @fields
              @validateField(f, i)

        c = @$$childHead
        if c != @
          while c
            if c.validateAllFields?
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

      $scope.validate = (_start, _end, fields) ->
        that = @
        if !that.validator
          $timeout( ->
            that.validateField(field, idx)
          , 10)
        else
          @removeErrors()
          if that.rows?.length?
            for i in [Math.max(0, _start)..Math.min(_end, that.rows.length - 1)]
              err = that.validator.validate(that.rows, fields, i)
              if err and err.length
                that.addErrors(err)
          $timeout( ->
            that.$apply(that.form.$errors)
          )
#          console.log "$scope.validate", err, @

      $scope.validateField = (field, idx) ->
        that = @
        if !that.validator
          $timeout( ->
            that.validateField(field, idx)
          , 10)
        else
          @removeErrors(field, idx)
          err = _.clone(that.validator.validateField(that.rows, field, idx))
          if err and err.length
            that.addErrors(err)
          $timeout( ->
            that.$apply(that.form.$errors)
          )
#          console.log "$scope.validateField", field.fieldname, idx, err, @

      $scope.subformInit = () ->
        @form = @$parent.fields[@$parent.fi].subform
        @fields = @form.fields
#        row = @$parent.rows[@$parent.$index]
#        if row[@$parent.fields[@fi].fieldname]
#          @rows = row[@$parent.fields[@fi].fieldname]
#          if !angular.isArray(@rows)
#            @rows = [@rows]

      $scope.subfieldInit = () ->
        @fields = @$parent.fields[@$parent.fi].fields
#        @form = { name: 'subfield', layout: { type: 'form', style: 'horizontal'}, fields: @fields }
#        row = @$parent.rows[@$parent.$index]
#        if row[@$parent.fields[@fi].fieldname]
#          @rows = row[@$parent.fields[@fi].fieldname]
#          if !angular.isArray(@rows)
#            @rows = [@rows]

      $scope.submit = () ->
        @save()


    initDisplay: ($scope) ->


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
        return (if @sort.reverse then '-' else '') + @sort.sortingOrder

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
          @form.model.sort = @sortQuery()
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
      scope = element.scope()
      if scope.form? and scope.form.layout.type == 'display'
        e = element.find('label')
      else
        e = element.find('input')

      if !e or e.length == 0
        e = element.find('span')

      return e

    modelSchema: (modelName, cb) ->
      $http.get('/api/{0}?action=schema'.format(modelName))
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
        else if t is 'object' and o?
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
                  label: _.str.humanize(cf.join(' '))
                  type: 'subform'
                  fieldname: f
                  subform:
                    label: _.str.humanize(cf.join(' '))
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
            label = _.str.humanize(fn)

          _type = "string"
          if p.instance
            _type = p.instance.toLowerCase()
          _type = objectToType(fn, _type, p.object)

          options = null
          if p.options and p.options.enum
            i = 0
            options = []
            for e in p.options.enum
              if e and e.length
                if !e.label and !e.value
                  options.push({value:i, label:e})
                else
                  options.push(e)

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
  '$location'

  (dynForm, $modal, $rootScope, $location) ->

    showModal: (title, scope, template, cb) ->

      ModalInstanceCtrl = ($scope, $modalInstance) ->

        $scope.modalClick = (url) ->
          if url == 'ok'
            $modalInstance.close()
          else if url == 'cancel'
            $modalInstance.dismiss()
          else
            $location.path(url)

      modalTemplate =
        '<div ng-controller="dynModalCtrl">' +
        '  <div class="modal-header">' +
        '    <button class="close" type="button" ng-click="modalClick(\'cancel\')">&times;</button>' +
        '    <h4 class="modal-title">' + title + '</h4>' +
        '  </div>' +
        '  <div class="modal-body">' +
        '    <!-- <template>-->' +
        '  </div>' +
        '  <div class="modal-footer">' +
        '    <input class="btn btn-default" type="button" ng-click="modalClick(\'cancel\')" value="Close"/>' +
        '  </div>'

#      console.log scope, modalTemplate, template
      modal = $modal.open(
        scope: scope
        template: modalTemplate.replace(/\<\!-- \<template\>--\>/g, template)
#        template: template
        controller: ModalInstanceCtrl
#          windowClass: ''
        size: 'lg'
        backdrop: 'static'
      )

      modal.result.then(
        () ->
          cb(true) if cb
      , () ->
          cb(false) if cb
      )

    showModalForm: (formDefinition, model, cb) ->

      ModalInstanceCtrl = ($scope, $modalInstance) ->

        $scope.modalClick = (url) ->
          if url == 'ok'
            $modalInstance.close()
          else if url == 'cancel'
            $modalInstance.dismiss()
          else
            $location.path(url)

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
        , () ->
            cb(false) if cb
        )
      )

    inputModal: (title, caption, cb) ->
      model = [{answer: ''}]
      formDefinition =
        label: title
        name: "modalForm"
        size: 'md'
        layout: {type: 'modal', style: 'horizontal'}
        buttons: [{ icon: null, class: 'success', label: 'OK', url: "ok" }, { icon: null, class: 'danger', label: 'Cancel', url: "cancel" }]

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
        buttons: [{ icon: null, class: 'success', label: 'YES', url: "ok" }, { icon: null, class: 'danger', label: 'NO', url: "cancel" }]
        autolabel: false

        fields: [
          column: 2
          type: "icon"
          value: "cic-question22"
          fontsize: 40
          shadow: 2
          vcenter: true
        ,
          column: 10
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
        buttons: [{ icon: 'cic-check', class: 'success', label: 'OK', url: "ok" }]
        autolabel: false

        fields: [
          column: 2
          rowSize: 'sm'
          type: "icon"
          value: "cic-exclamation2"
          fontsize: 40
          vcenter: true
          shadow: 2
        ,
          column: 10
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
        buttons: [{ icon: 'cic-check', class: 'success', label: 'OK', url: "ok" }]
        autolabel: false

        fields: [
          column: 2
          rowSize: 'sm'
          type: "icon"
          value: "info6"
          fontsize: 40
          shadow: 2
        ,
          column: 10
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
        buttons: [{ icon: null, class: 'success', label: 'OK', url: "ok" }, { icon: null, class: 'danger', label: 'Cancel', url: "cancel" }]
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

.controller('dynDisplayCtrl', [
  '$scope'
  'Globals'
  'dynForm'

  ($scope, globals, dynForm) ->
    dynForm.initScope($scope)
    dynForm.initDisplay($scope)
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

    $scope.checkItem = (item, model) ->
      l = model
      if !l or !angular.isArray(l)
        l = []
      i = l.indexOf(item.value)
      if i == -1
        l.push(item.value)
      else
        l.splice(i, 1)
      console.log l
      return l

#    $scope.check = (item, model) ->
#      item.checked = !item.checked
#      model.assign(item.checked)
#      console.log "check()", item, $scope.ngModel

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
        if k != "label" and k != "type" and k != "description" and k != "fieldname" and k != "config" and k != "options" and k != "dompath" and k != "show" and k[0] != "_" and k != "value"
          attributes.process(scope, element, k, field)
])

.factory('attributes', [
  '$compile'
  'dynForm'
  'numberAttributes'
  'dateAttributes'
  'layoutAttributes'
  'stringAttributes'
  'iconspickerAttributes'

  ($compile, dynForm, numbers, dates, layouts, strings, iconspicker) ->
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

    data.store = angular.extend(data.store, numbers, dates, layouts, strings, iconspicker)

    return data
])

.directive('dynAttrs', [
  '$parse'
  '$compile'

  ($parse, $compile) ->
    restrict: 'A'
    priority: 1

    link: (scope, element, attrs) ->
      fields = $parse(element.attr('dyn-attrs'))(scope)
      if fields
        for k in Object.keys(fields)
          element.attr(k, fields[k])
      element.removeAttr('dyn-attrs')
      $compile(element)(scope)
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
          return 'cic cic-sort-' + (if scope.sort.reverse then 'up' else 'down')
        else
          return 'cic cic-sort'
])

.directive('wtFieldWatch', [

  () ->
    restrict: 'A'
    replace: true
    template: '<div>Value<div class="alert alert-info">{{value}}</div></div>'
    scope:
      value: '='
])



countries = [
  "Afghanistan", "Albania", "Algeria", "American Samoa", "Angola", "Anguilla", "Antartica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Ashmore and Cartier Island", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Clipperton Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo, Democratic Republic of the", "Congo, Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Cyprus", "Czeck Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Europa Island", "Falkland Islands (Islas Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern and Antarctic Lands", "Gabon", "Gambia, The", "Gaza Strip", "Georgia", "Germany", "Ghana", "Gibraltar", "Glorioso Islands", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard Island and McDonald Islands", "Holy See (Vatican City)", "Honduras", "Hong Kong", "Howland Island", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Ireland, Northern", "Israel", "Italy", "Jamaica", "Jan Mayen", "Japan", "Jarvis Island", "Jersey", "Johnston Atoll", "Jordan", "Juan de Nova Island", "Kazakhstan", "Kenya", "Kiribati", "Korea, North", "Korea, South", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia, Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Man, Isle of", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Midway Islands", "Moldova", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcaim Islands", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romainia", "Russia", "Rwanda", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Scotland", "Senegal", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and South Sandwich Islands", "Spain", "Spratly Islands", "Sri Lanka", "Sudan", "Suriname", "Svalbard", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Tobago", "Toga", "Tokelau", "Tonga", "Trinidad", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "Uruguay", "USA", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Virgin Islands", "Wales", "Wallis and Futuna", "West Bank", "Western Sahara", "Yemen", "Yugoslavia", "Zambia", "Zimbabwe"
]

states = [
  "Badakhshan|Badghis|Baghlan|Balkh|Bamian|Farah|Faryab|Ghazni|Ghowr|Helmand|Herat|Jowzjan|Kabol|Kandahar|Kapisa|Konar|Kondoz|Laghman|Lowgar|Nangarhar|Nimruz|Oruzgan|Paktia|Paktika|Parvan|Samangan|Sar-e Pol|Takhar|Vardak|Zabol"
  "Berat|Bulqize|Delvine|Devoll (Bilisht)|Diber (Peshkopi)|Durres|Elbasan|Fier|Gjirokaster|Gramsh|Has (Krume)|Kavaje|Kolonje (Erseke)|Korce|Kruje|Kucove|Kukes|Kurbin|Lezhe|Librazhd|Lushnje|Malesi e Madhe (Koplik)|Mallakaster (Ballsh)|Mat (Burrel)|Mirdite (Rreshen)|Peqin|Permet|Pogradec|Puke|Sarande|Shkoder|Skrapar (Corovode)|Tepelene|Tirane (Tirana)|Tirane (Tirana)|Tropoje (Bajram Curri)|Vlore"
  "Adrar|Ain Defla|Ain Temouchent|Alger|Annaba|Batna|Bechar|Bejaia|Biskra|Blida|Bordj Bou Arreridj|Bouira|Boumerdes|Chlef|Constantine|Djelfa|El Bayadh|El Oued|El Tarf|Ghardaia|Guelma|Illizi|Jijel|Khenchela|Laghouat|M'Sila|Mascara|Medea|Mila|Mostaganem|Naama|Oran|Ouargla|Oum el Bouaghi|Relizane|Saida|Setif|Sidi Bel Abbes|Skikda|Souk Ahras|Tamanghasset|Tebessa|Tiaret|Tindouf|Tipaza|Tissemsilt|Tizi Ouzou|Tlemcen"
  "Eastern|Manu'a|Rose Island|Swains Island|Western"
  "Andorra la Vella|Bengo|Benguela|Bie|Cabinda|Canillo|Cuando Cubango|Cuanza Norte|Cuanza Sul|Cunene|Encamp|Escaldes-Engordany|Huambo|Huila|La Massana|Luanda|Lunda Norte|Lunda Sul|Malanje|Moxico|Namibe|Ordino|Sant Julia de Loria|Uige|Zaire"
  "Anguilla"
  "Antartica"
  "Barbuda|Redonda|Saint George|Saint John|Saint Mary|Saint Paul|Saint Peter|Saint Philip"
  "Antartica e Islas del Atlantico Sur|Buenos Aires|Buenos Aires Capital Federal|Catamarca|Chaco|Chubut|Cordoba|Corrientes|Entre Rios|Formosa|Jujuy|La Pampa|La Rioja|Mendoza|Misiones|Neuquen|Rio Negro|Salta|San Juan|San Luis|Santa Cruz|Santa Fe|Santiago del Estero|Tierra del Fuego|Tucuman"
  "Aragatsotn|Ararat|Armavir|Geghark'unik'|Kotayk'|Lorri|Shirak|Syunik'|Tavush|Vayots' Dzor|Yerevan"
  "Aruba"
  "Ashmore and Cartier Island"
  "Australian Capital Territory|New South Wales|Northern Territory|Queensland|South Australia|Tasmania|Victoria|Western Australia"
  "Burgenland|Kaernten|Niederoesterreich|Oberoesterreich|Salzburg|Steiermark|Tirol|Vorarlberg|Wien"
  "Abseron Rayonu|Agcabadi Rayonu|Agdam Rayonu|Agdas Rayonu|Agstafa Rayonu|Agsu Rayonu|Ali Bayramli Sahari|Astara Rayonu|Baki Sahari|Balakan Rayonu|Barda Rayonu|Beylaqan Rayonu|Bilasuvar Rayonu|Cabrayil Rayonu|Calilabad Rayonu|Daskasan Rayonu|Davaci Rayonu|Fuzuli Rayonu|Gadabay Rayonu|Ganca Sahari|Goranboy Rayonu|Goycay Rayonu|Haciqabul Rayonu|Imisli Rayonu|Ismayilli Rayonu|Kalbacar Rayonu|Kurdamir Rayonu|Lacin Rayonu|Lankaran Rayonu|Lankaran Sahari|Lerik Rayonu|Masalli Rayonu|Mingacevir Sahari|Naftalan Sahari|Naxcivan Muxtar Respublikasi|Neftcala Rayonu|Oguz Rayonu|Qabala Rayonu|Qax Rayonu|Qazax Rayonu|Qobustan Rayonu|Quba Rayonu|Qubadli Rayonu|Qusar Rayonu|Saatli Rayonu|Sabirabad Rayonu|Saki Rayonu|Saki Sahari|Salyan Rayonu|Samaxi Rayonu|Samkir Rayonu|Samux Rayonu|Siyazan Rayonu|Sumqayit Sahari|Susa Rayonu|Susa Sahari|Tartar Rayonu|Tovuz Rayonu|Ucar Rayonu|Xacmaz Rayonu|Xankandi Sahari|Xanlar Rayonu|Xizi Rayonu|Xocali Rayonu|Xocavand Rayonu|Yardimli Rayonu|Yevlax Rayonu|Yevlax Sahari|Zangilan Rayonu|Zaqatala Rayonu|Zardab Rayonu"
  "Acklins and Crooked Islands|Bimini|Cat Island|Exuma|Freeport|Fresh Creek|Governor's Harbour|Green Turtle Cay|Harbour Island|High Rock|Inagua|Kemps Bay|Long Island|Marsh Harbour|Mayaguana|New Providence|Nicholls Town and Berry Islands|Ragged Island|Rock Sound|San Salvador and Rum Cay|Sandy Point"
  "Al Hadd|Al Manamah|Al Mintaqah al Gharbiyah|Al Mintaqah al Wusta|Al Mintaqah ash Shamaliyah|Al Muharraq|Ar Rifa' wa al Mintaqah al Janubiyah|Jidd Hafs|Juzur Hawar|Madinat 'Isa|Madinat Hamad|Sitrah"
  "Barguna|Barisal|Bhola|Jhalokati|Patuakhali|Pirojpur|Bandarban|Brahmanbaria|Chandpur|Chittagong|Comilla|Cox's Bazar|Feni|Khagrachari|Lakshmipur|Noakhali|Rangamati|Dhaka|Faridpur|Gazipur|Gopalganj|Jamalpur|Kishoreganj|Madaripur|Manikganj|Munshiganj|Mymensingh|Narayanganj|Narsingdi|Netrokona|Rajbari|Shariatpur|Sherpur|Tangail|Bagerhat|Chuadanga|Jessore|Jhenaidah|Khulna|Kushtia|Magura|Meherpur|Narail|Satkhira|Bogra|Dinajpur|Gaibandha|Jaipurhat|Kurigram|Lalmonirhat|Naogaon|Natore|Nawabganj|Nilphamari|Pabna|Panchagarh|Rajshahi|Rangpur|Sirajganj|Thakurgaon|Habiganj|Maulvi bazar|Sunamganj|Sylhet"
  "Bridgetown|Christ Church|Saint Andrew|Saint George|Saint James|Saint John|Saint Joseph|Saint Lucy|Saint Michael|Saint Peter|Saint Philip|Saint Thomas"
  "Brestskaya (Brest)|Homyel'skaya (Homyel')|Horad Minsk|Hrodzyenskaya (Hrodna)|Mahilyowskaya (Mahilyow)|Minskaya|Vitsyebskaya (Vitsyebsk)"
  "Antwerpen|Brabant Wallon|Brussels Capitol Region|Hainaut|Liege|Limburg|Luxembourg|Namur|Oost-Vlaanderen|Vlaams Brabant|West-Vlaanderen"
  "Belize|Cayo|Corozal|Orange Walk|Stann Creek|Toledo"
  "Alibori|Atakora|Atlantique|Borgou|Collines|Couffo|Donga|Littoral|Mono|Oueme|Plateau|Zou"
  "Devonshire|Hamilton|Hamilton|Paget|Pembroke|Saint George|Saint Georges|Sandys|Smiths|Southampton|Warwick"
  "Bumthang|Chhukha|Chirang|Daga|Geylegphug|Ha|Lhuntshi|Mongar|Paro|Pemagatsel|Punakha|Samchi|Samdrup Jongkhar|Shemgang|Tashigang|Thimphu|Tongsa|Wangdi Phodrang"
  "Beni|Chuquisaca|Cochabamba|La Paz|Oruro|Pando|Potosi|Santa Cruz|Tarija"
  "Federation of Bosnia and Herzegovina|Republika Srpska"
  "Central|Chobe|Francistown|Gaborone|Ghanzi|Kgalagadi|Kgatleng|Kweneng|Lobatse|Ngamiland|North-East|Selebi-Pikwe|South-East|Southern"
  "Acre|Alagoas|Amapa|Amazonas|Bahia|Ceara|Distrito Federal|Espirito Santo|Goias|Maranhao|Mato Grosso|Mato Grosso do Sul|Minas Gerais|Para|Paraiba|Parana|Pernambuco|Piaui|Rio de Janeiro|Rio Grande do Norte|Rio Grande do Sul|Rondonia|Roraima|Santa Catarina|Sao Paulo|Sergipe|Tocantins"
  "Anegada|Jost Van Dyke|Tortola|Virgin Gorda"
  "Belait|Brunei and Muara|Temburong|Tutong"
  "Blagoevgrad|Burgas|Dobrich|Gabrovo|Khaskovo|Kurdzhali|Kyustendil|Lovech|Montana|Pazardzhik|Pernik|Pleven|Plovdiv|Razgrad|Ruse|Shumen|Silistra|Sliven|Smolyan|Sofiya|Sofiya-Grad|Stara Zagora|Turgovishte|Varna|Veliko Turnovo|Vidin|Vratsa|Yambol"
  "Bale|Bam|Banwa|Bazega|Bougouriba|Boulgou|Boulkiemde|Comoe|Ganzourgou|Gnagna|Gourma|Houet|Ioba|Kadiogo|Kenedougou|Komandjari|Kompienga|Kossi|Koupelogo|Kouritenga|Kourweogo|Leraba|Loroum|Mouhoun|Nahouri|Namentenga|Naumbiel|Nayala|Oubritenga|Oudalan|Passore|Poni|Samentenga|Sanguie|Seno|Sissili|Soum|Sourou|Tapoa|Tuy|Yagha|Yatenga|Ziro|Zondomo|Zoundweogo"
  "Ayeyarwady|Bago|Chin State|Kachin State|Kayah State|Kayin State|Magway|Mandalay|Mon State|Rakhine State|Sagaing|Shan State|Tanintharyi|Yangon"
  "Bubanza|Bujumbura|Bururi|Cankuzo|Cibitoke|Gitega|Karuzi|Kayanza|Kirundo|Makamba|Muramvya|Muyinga|Mwaro|Ngozi|Rutana|Ruyigi"
  "Banteay Mean Cheay|Batdambang|Kampong Cham|Kampong Chhnang|Kampong Spoe|Kampong Thum|Kampot|Kandal|Kaoh Kong|Keb|Kracheh|Mondol Kiri|Otdar Mean Cheay|Pailin|Phnum Penh|Pouthisat|Preah Seihanu (Sihanoukville)|Preah Vihear|Prey Veng|Rotanah Kiri|Siem Reab|Stoeng Treng|Svay Rieng|Takev"
  "Adamaoua|Centre|Est|Extreme-Nord|Littoral|Nord|Nord-Ouest|Ouest|Sud|Sud-Ouest"
  "Alberta|British Columbia|Manitoba|New Brunswick|Newfoundland|Northwest Territories|Nova Scotia|Nunavut|Ontario|Prince Edward Island|Quebec|Saskatchewan|Yukon Territory"
  "Boa Vista|Brava|Maio|Mosteiros|Paul|Porto Novo|Praia|Ribeira Grande|Sal|Santa Catarina|Santa Cruz|Sao Domingos|Sao Filipe|Sao Nicolau|Sao Vicente|Tarrafal"
  "Creek|Eastern|Midland|South Town|Spot Bay|Stake Bay|West End|Western"
  "Bamingui-Bangoran|Bangui|Basse-Kotto|Gribingui|Haut-Mbomou|Haute-Kotto|Haute-Sangha|Kemo-Gribingui|Lobaye|Mbomou|Nana-Mambere|Ombella-Mpoko|Ouaka|Ouham|Ouham-Pende|Sangha|Vakaga"
  "Batha|Biltine|Borkou-Ennedi-Tibesti|Chari-Baguirmi|Guera|Kanem|Lac|Logone Occidental|Logone Oriental|Mayo-Kebbi|Moyen-Chari|Ouaddai|Salamat|Tandjile"
  "Aisen del General Carlos Ibanez del Campo|Antofagasta|Araucania|Atacama|Bio-Bio|Coquimbo|Libertador General Bernardo O'Higgins|Los Lagos|Magallanes y de la Antartica Chilena|Maule|Region Metropolitana (Santiago)|Tarapaca|Valparaiso"
  "Anhui|Beijing|Chongqing|Fujian|Gansu|Guangdong|Guangxi|Guizhou|Hainan|Hebei|Heilongjiang|Henan|Hubei|Hunan|Jiangsu|Jiangxi|Jilin|Liaoning|Nei Mongol|Ningxia|Qinghai|Shaanxi|Shandong|Shanghai|Shanxi|Sichuan|Tianjin|Xinjiang|Xizang (Tibet)|Yunnan|Zhejiang"
  "Christmas Island"
  "Clipperton Island"
  "Direction Island|Home Island|Horsburgh Island|North Keeling Island|South Island|West Island"
  "Amazonas|Antioquia|Arauca|Atlantico|Bolivar|Boyaca|Caldas|Caqueta|Casanare|Cauca|Cesar|Choco|Cordoba|Cundinamarca|Distrito Capital de Santa Fe de Bogota|Guainia|Guaviare|Huila|La Guajira|Magdalena|Meta|Narino|Norte de Santander|Putumayo|Quindio|Risaralda|San Andres y Providencia|Santander|Sucre|Tolima|Valle del Cauca|Vaupes|Vichada"
  "Anjouan (Nzwani)|Domoni|Fomboni|Grande Comore (Njazidja)|Moheli (Mwali)|Moroni|Moutsamoudou"
  "Bandundu|Bas-Congo|Equateur|Kasai-Occidental|Kasai-Oriental|Katanga|Kinshasa|Maniema|Nord-Kivu|Orientale|Sud-Kivu"
  "Bouenza|Brazzaville|Cuvette|Kouilou|Lekoumou|Likouala|Niari|Plateaux|Pool|Sangha"
  "Aitutaki|Atiu|Avarua|Mangaia|Manihiki|Manuae|Mauke|Mitiaro|Nassau Island|Palmerston|Penrhyn|Pukapuka|Rakahanga|Rarotonga|Suwarrow|Takutea"
  "Alajuela|Cartago|Guanacaste|Heredia|Limon|Puntarenas|San Jose"
  "Abengourou|Abidjan|Aboisso|Adiake'|Adzope|Agboville|Agnibilekrou|Ale'pe'|Bangolo|Beoumi|Biankouma|Bocanda|Bondoukou|Bongouanou|Bouafle|Bouake|Bouna|Boundiali|Dabakala|Dabon|Daloa|Danane|Daoukro|Dimbokro|Divo|Duekoue|Ferkessedougou|Gagnoa|Grand Bassam|Grand-Lahou|Guiglo|Issia|Jacqueville|Katiola|Korhogo|Lakota|Man|Mankono|Mbahiakro|Odienne|Oume|Sakassou|San-Pedro|Sassandra|Seguela|Sinfra|Soubre|Tabou|Tanda|Tiassale|Tiebissou|Tingrela|Touba|Toulepleu|Toumodi|Vavoua|Yamoussoukro|Zuenoula"
  "Bjelovarsko-Bilogorska Zupanija|Brodsko-Posavska Zupanija|Dubrovacko-Neretvanska Zupanija|Istarska Zupanija|Karlovacka Zupanija|Koprivnicko-Krizevacka Zupanija|Krapinsko-Zagorska Zupanija|Licko-Senjska Zupanija|Medimurska Zupanija|Osjecko-Baranjska Zupanija|Pozesko-Slavonska Zupanija|Primorsko-Goranska Zupanija|Sibensko-Kninska Zupanija|Sisacko-Moslavacka Zupanija|Splitsko-Dalmatinska Zupanija|Varazdinska Zupanija|Viroviticko-Podravska Zupanija|Vukovarsko-Srijemska Zupanija|Zadarska Zupanija|Zagreb|Zagrebacka Zupanija"
  "Camaguey|Ciego de Avila|Cienfuegos|Ciudad de La Habana|Granma|Guantanamo|Holguin|Isla de la Juventud|La Habana|Las Tunas|Matanzas|Pinar del Rio|Sancti Spiritus|Santiago de Cuba|Villa Clara"
  "Famagusta|Kyrenia|Larnaca|Limassol|Nicosia|Paphos"
  "Brnensky|Budejovicky|Jihlavsky|Karlovarsky|Kralovehradecky|Liberecky|Olomoucky|Ostravsky|Pardubicky|Plzensky|Praha|Stredocesky|Ustecky|Zlinsky"
  "Arhus|Bornholm|Fredericksberg|Frederiksborg|Fyn|Kobenhavn|Kobenhavns|Nordjylland|Ribe|Ringkobing|Roskilde|Sonderjylland|Storstrom|Vejle|Vestsjalland|Viborg"
  "'Ali Sabih|Dikhil|Djibouti|Obock|Tadjoura"
  "Saint Andrew|Saint David|Saint George|Saint John|Saint Joseph|Saint Luke|Saint Mark|Saint Patrick|Saint Paul|Saint Peter"
  "Azua|Baoruco|Barahona|Dajabon|Distrito Nacional|Duarte|El Seibo|Elias Pina|Espaillat|Hato Mayor|Independencia|La Altagracia|La Romana|La Vega|Maria Trinidad Sanchez|Monsenor Nouel|Monte Cristi|Monte Plata|Pedernales|Peravia|Puerto Plata|Salcedo|Samana|San Cristobal|San Juan|San Pedro de Macoris|Sanchez Ramirez|Santiago|Santiago Rodriguez|Valverde"
  "Azuay|Bolivar|Canar|Carchi|Chimborazo|Cotopaxi|El Oro|Esmeraldas|Galapagos|Guayas|Imbabura|Loja|Los Rios|Manabi|Morona-Santiago|Napo|Orellana|Pastaza|Pichincha|Sucumbios|Tungurahua|Zamora-Chinchipe"
  "Ad Daqahliyah|Al Bahr al Ahmar|Al Buhayrah|Al Fayyum|Al Gharbiyah|Al Iskandariyah|Al Isma'iliyah|Al Jizah|Al Minufiyah|Al Minya|Al Qahirah|Al Qalyubiyah|Al Wadi al Jadid|As Suways|Ash Sharqiyah|Aswan|Asyut|Bani Suwayf|Bur Sa'id|Dumyat|Janub Sina'|Kafr ash Shaykh|Matruh|Qina|Shamal Sina'|Suhaj"
  "Ahuachapan|Cabanas|Chalatenango|Cuscatlan|La Libertad|La Paz|La Union|Morazan|San Miguel|San Salvador|San Vicente|Santa Ana|Sonsonate|Usulutan"
  "Annobon|Bioko Norte|Bioko Sur|Centro Sur|Kie-Ntem|Litoral|Wele-Nzas"
  "Akale Guzay|Barka|Denkel|Hamasen|Sahil|Semhar|Senhit|Seraye"
  "Harjumaa (Tallinn)|Hiiumaa (Kardla)|Ida-Virumaa (Johvi)|Jarvamaa (Paide)|Jogevamaa (Jogeva)|Laane-Virumaa (Rakvere)|Laanemaa (Haapsalu)|Parnumaa (Parnu)|Polvamaa (Polva)|Raplamaa (Rapla)|Saaremaa (Kuessaare)|Tartumaa (Tartu)|Valgamaa (Valga)|Viljandimaa (Viljandi)|Vorumaa (Voru)"
  "Adis Abeba (Addis Ababa)|Afar|Amara|Dire Dawa|Gambela Hizboch|Hareri Hizb|Oromiya|Sumale|Tigray|YeDebub Biheroch Bihereseboch na Hizboch"
  "Europa Island"
  "Falkland Islands (Islas Malvinas)"
  "Bordoy|Eysturoy|Mykines|Sandoy|Skuvoy|Streymoy|Suduroy|Tvoroyri|Vagar"
  "Central|Eastern|Northern|Rotuma|Western"
  "Aland|Etela-Suomen Laani|Ita-Suomen Laani|Lansi-Suomen Laani|Lappi|Oulun Laani"
  "Alsace|Aquitaine|Auvergne|Basse-Normandie|Bourgogne|Bretagne|Centre|Champagne-Ardenne|Corse|Franche-Comte|Haute-Normandie|Ile-de-France|Languedoc-Roussillon|Limousin|Lorraine|Midi-Pyrenees|Nord-Pas-de-Calais|Pays de la Loire|Picardie|Poitou-Charentes|Provence-Alpes-Cote d'Azur|Rhone-Alpes"
  "French Guiana"
  "Archipel des Marquises|Archipel des Tuamotu|Archipel des Tubuai|Iles du Vent|Iles Sous-le-Vent"
  "Adelie Land|Ile Crozet|Iles Kerguelen|Iles Saint-Paul et Amsterdam"
  "Estuaire|Haut-Ogooue|Moyen-Ogooue|Ngounie|Nyanga|Ogooue-Ivindo|Ogooue-Lolo|Ogooue-Maritime|Woleu-Ntem"
  "Banjul|Central River|Lower River|North Bank|Upper River|Western"
  "Gaza Strip"
  "Abashis|Abkhazia or Ap'khazet'is Avtonomiuri Respublika (Sokhumi)|Adigenis|Ajaria or Acharis Avtonomiuri Respublika (Bat'umi)|Akhalgoris|Akhalk'alak'is|Akhalts'ikhis|Akhmetis|Ambrolauris|Aspindzis|Baghdat'is|Bolnisis|Borjomis|Ch'khorotsqus|Ch'okhatauris|Chiat'ura|Dedop'listsqaros|Dmanisis|Dushet'is|Gardabanis|Gori|Goris|Gurjaanis|Javis|K'arelis|K'ut'aisi|Kaspis|Kharagaulis|Khashuris|Khobis|Khonis|Lagodekhis|Lanch'khut'is|Lentekhis|Marneulis|Martvilis|Mestiis|Mts'khet'is|Ninotsmindis|Onis|Ozurget'is|P'ot'i|Qazbegis|Qvarlis|Rust'avi|Sach'kheris|Sagarejos|Samtrediis|Senakis|Sighnaghis|T'bilisi|T'elavis|T'erjolis|T'et'ritsqaros|T'ianet'is|Tqibuli|Ts'ageris|Tsalenjikhis|Tsalkis|Tsqaltubo|Vanis|Zestap'onis|Zugdidi|Zugdidis"
  "Baden-Wuerttemberg|Bayern|Berlin|Brandenburg|Bremen|Hamburg|Hessen|Mecklenburg-Vorpommern|Niedersachsen|Nordrhein-Westfalen|Rheinland-Pfalz|Saarland|Sachsen|Sachsen-Anhalt|Schleswig-Holstein|Thueringen"
  "Ashanti|Brong-Ahafo|Central|Eastern|Greater Accra|Northern|Upper East|Upper West|Volta|Western"
  "Gibraltar"
  "Ile du Lys|Ile Glorieuse"
  "Aitolia kai Akarnania|Akhaia|Argolis|Arkadhia|Arta|Attiki|Ayion Oros (Mt. Athos)|Dhodhekanisos|Drama|Evritania|Evros|Evvoia|Florina|Fokis|Fthiotis|Grevena|Ilia|Imathia|Ioannina|Irakleion|Kardhitsa|Kastoria|Kavala|Kefallinia|Kerkyra|Khalkidhiki|Khania|Khios|Kikladhes|Kilkis|Korinthia|Kozani|Lakonia|Larisa|Lasithi|Lesvos|Levkas|Magnisia|Messinia|Pella|Pieria|Preveza|Rethimni|Rodhopi|Samos|Serrai|Thesprotia|Thessaloniki|Trikala|Voiotia|Xanthi|Zakinthos"
  "Avannaa (Nordgronland)|Kitaa (Vestgronland)|Tunu (Ostgronland)"
  "Carriacou and Petit Martinique|Saint Andrew|Saint David|Saint George|Saint John|Saint Mark|Saint Patrick"
  "Basse-Terre|Grande-Terre|Iles de la Petite Terre|Iles des Saintes|Marie-Galante"
  "Guam"
  "Alta Verapaz|Baja Verapaz|Chimaltenango|Chiquimula|El Progreso|Escuintla|Guatemala|Huehuetenango|Izabal|Jalapa|Jutiapa|Peten|Quetzaltenango|Quiche|Retalhuleu|Sacatepequez|San Marcos|Santa Rosa|Solola|Suchitepequez|Totonicapan|Zacapa"
  "Castel|Forest|St. Andrew|St. Martin|St. Peter Port|St. Pierre du Bois|St. Sampson|St. Saviour|Torteval|Vale"
  "Beyla|Boffa|Boke|Conakry|Coyah|Dabola|Dalaba|Dinguiraye|Dubreka|Faranah|Forecariah|Fria|Gaoual|Gueckedou|Kankan|Kerouane|Kindia|Kissidougou|Koubia|Koundara|Kouroussa|Labe|Lelouma|Lola|Macenta|Mali|Mamou|Mandiana|Nzerekore|Pita|Siguiri|Telimele|Tougue|Yomou"
  "Bafata|Biombo|Bissau|Bolama-Bijagos|Cacheu|Gabu|Oio|Quinara|Tombali"
  "Barima-Waini|Cuyuni-Mazaruni|Demerara-Mahaica|East Berbice-Corentyne|Essequibo Islands-West Demerara|Mahaica-Berbice|Pomeroon-Supenaam|Potaro-Siparuni|Upper Demerara-Berbice|Upper Takutu-Upper Essequibo"
  "Artibonite|Centre|Grand'Anse|Nord|Nord-Est|Nord-Ouest|Ouest|Sud|Sud-Est"
  "Heard Island and McDonald Islands"
  "Holy See (Vatican City)"
  "Atlantida|Choluteca|Colon|Comayagua|Copan|Cortes|El Paraiso|Francisco Morazan|Gracias a Dios|Intibuca|Islas de la Bahia|La Paz|Lempira|Ocotepeque|Olancho|Santa Barbara|Valle|Yoro"
  "Hong Kong"
  "Howland Island"
  "Bacs-Kiskun|Baranya|Bekes|Bekescsaba|Borsod-Abauj-Zemplen|Budapest|Csongrad|Debrecen|Dunaujvaros|Eger|Fejer|Gyor|Gyor-Moson-Sopron|Hajdu-Bihar|Heves|Hodmezovasarhely|Jasz-Nagykun-Szolnok|Kaposvar|Kecskemet|Komarom-Esztergom|Miskolc|Nagykanizsa|Nograd|Nyiregyhaza|Pecs|Pest|Somogy|Sopron|Szabolcs-Szatmar-Bereg|Szeged|Szekesfehervar|Szolnok|Szombathely|Tatabanya|Tolna|Vas|Veszprem|Veszprem|Zala|Zalaegerszeg"
  "Akranes|Akureyri|Arnessysla|Austur-Bardhastrandarsysla|Austur-Hunavatnssysla|Austur-Skaftafellssysla|Borgarfjardharsysla|Dalasysla|Eyjafjardharsysla|Gullbringusysla|Hafnarfjordhur|Husavik|Isafjordhur|Keflavik|Kjosarsysla|Kopavogur|Myrasysla|Neskaupstadhur|Nordhur-Isafjardharsysla|Nordhur-Mulasys-la|Nordhur-Thingeyjarsysla|Olafsfjordhur|Rangarvallasysla|Reykjavik|Saudharkrokur|Seydhisfjordhur|Siglufjordhur|Skagafjardharsysla|Snaefellsnes-og Hnappadalssysla|Strandasysla|Sudhur-Mulasysla|Sudhur-Thingeyjarsysla|Vesttmannaeyjar|Vestur-Bardhastrandarsysla|Vestur-Hunavatnssysla|Vestur-Isafjardharsysla|Vestur-Skaftafellssysla"
  "Andaman and Nicobar Islands|Andhra Pradesh|Arunachal Pradesh|Assam|Bihar|Chandigarh|Chhattisgarh|Dadra and Nagar Haveli|Daman and Diu|Delhi|Goa|Gujarat|Haryana|Himachal Pradesh|Jammu and Kashmir|Jharkhand|Karnataka|Kerala|Lakshadweep|Madhya Pradesh|Maharashtra|Manipur|Meghalaya|Mizoram|Nagaland|Orissa|Pondicherry|Punjab|Rajasthan|Sikkim|Tamil Nadu|Tripura|Uttar Pradesh|Uttaranchal|West Bengal"
  "Aceh|Bali|Banten|Bengkulu|East Timor|Gorontalo|Irian Jaya|Jakarta Raya|Jambi|Jawa Barat|Jawa Tengah|Jawa Timur|Kalimantan Barat|Kalimantan Selatan|Kalimantan Tengah|Kalimantan Timur|Kepulauan Bangka Belitung|Lampung|Maluku|Maluku Utara|Nusa Tenggara Barat|Nusa Tenggara Timur|Riau|Sulawesi Selatan|Sulawesi Tengah|Sulawesi Tenggara|Sulawesi Utara|Sumatera Barat|Sumatera Selatan|Sumatera Utara|Yogyakarta"
  "Ardabil|Azarbayjan-e Gharbi|Azarbayjan-e Sharqi|Bushehr|Chahar Mahall va Bakhtiari|Esfahan|Fars|Gilan|Golestan|Hamadan|Hormozgan|Ilam|Kerman|Kermanshah|Khorasan|Khuzestan|Kohgiluyeh va Buyer Ahmad|Kordestan|Lorestan|Markazi|Mazandaran|Qazvin|Qom|Semnan|Sistan va Baluchestan|Tehran|Yazd|Zanjan"
  "Al Anbar|Al Basrah|Al Muthanna|Al Qadisiyah|An Najaf|Arbil|As Sulaymaniyah|At Ta'mim|Babil|Baghdad|Dahuk|Dhi Qar|Diyala|Karbala'|Maysan|Ninawa|Salah ad Din|Wasit"
  "Carlow|Cavan|Clare|Cork|Donegal|Dublin|Galway|Kerry|Kildare|Kilkenny|Laois|Leitrim|Limerick|Longford|Louth|Mayo|Meath|Monaghan|Offaly|Roscommon|Sligo|Tipperary|Waterford|Westmeath|Wexford|Wicklow"
  "Antrim|Ards|Armagh|Ballymena|Ballymoney|Banbridge|Belfast|Carrickfergus|Castlereagh|Coleraine|Cookstown|Craigavon|Derry|Down|Dungannon|Fermanagh|Larne|Limavady|Lisburn|Magherafelt|Moyle|Newry and Mourne|Newtownabbey|North Down|Omagh|Strabane"
  "Central|Haifa|Jerusalem|Northern|Southern|Tel Aviv"
  "Abruzzo|Basilicata|Calabria|Campania|Emilia-Romagna|Friuli-Venezia Giulia|Lazio|Liguria|Lombardia|Marche|Molise|Piemonte|Puglia|Sardegna|Sicilia|Toscana|Trentino-Alto Adige|Umbria|Valle d'Aosta|Veneto"
  "Clarendon|Hanover|Kingston|Manchester|Portland|Saint Andrew|Saint Ann|Saint Catherine|Saint Elizabeth|Saint James|Saint Mary|Saint Thomas|Trelawny|Westmoreland"
  "Jan Mayen"
  "Aichi|Akita|Aomori|Chiba|Ehime|Fukui|Fukuoka|Fukushima|Gifu|Gumma|Hiroshima|Hokkaido|Hyogo|Ibaraki|Ishikawa|Iwate|Kagawa|Kagoshima|Kanagawa|Kochi|Kumamoto|Kyoto|Mie|Miyagi|Miyazaki|Nagano|Nagasaki|Nara|Niigata|Oita|Okayama|Okinawa|Osaka|Saga|Saitama|Shiga|Shimane|Shizuoka|Tochigi|Tokushima|Tokyo|Tottori|Toyama|Wakayama|Yamagata|Yamaguchi|Yamanashi"
  "Jarvis Island"
  "Jersey"
  "Johnston Atoll"
  "'Amman|Ajlun|Al 'Aqabah|Al Balqa'|Al Karak|Al Mafraq|At Tafilah|Az Zarqa'|Irbid|Jarash|Ma'an|Madaba"
  "Juan de Nova Island"
  "Almaty|Aqmola|Aqtobe|Astana|Atyrau|Batys Qazaqstan|Bayqongyr|Mangghystau|Ongtustik Qazaqstan|Pavlodar|Qaraghandy|Qostanay|Qyzylorda|Shyghys Qazaqstan|Soltustik Qazaqstan|Zhambyl"
  "Central|Coast|Eastern|Nairobi Area|North Eastern|Nyanza|Rift Valley|Western"
  "Abaiang|Abemama|Aranuka|Arorae|Banaba|Banaba|Beru|Butaritari|Central Gilberts|Gilbert Islands|Kanton|Kiritimati|Kuria|Line Islands|Line Islands|Maiana|Makin|Marakei|Nikunau|Nonouti|Northern Gilberts|Onotoa|Phoenix Islands|Southern Gilberts|Tabiteuea|Tabuaeran|Tamana|Tarawa|Tarawa|Teraina"
  "Chagang-do (Chagang Province)|Hamgyong-bukto (North Hamgyong Province)|Hamgyong-namdo (South Hamgyong Province)|Hwanghae-bukto (North Hwanghae Province)|Hwanghae-namdo (South Hwanghae Province)|Kaesong-si (Kaesong City)|Kangwon-do (Kangwon Province)|Namp'o-si (Namp'o City)|P'yongan-bukto (North P'yongan Province)|P'yongan-namdo (South P'yongan Province)|P'yongyang-si (P'yongyang City)|Yanggang-do (Yanggang Province)"
  "Ch'ungch'ong-bukto|Ch'ungch'ong-namdo|Cheju-do|Cholla-bukto|Cholla-namdo|Inch'on-gwangyoksi|Kangwon-do|Kwangju-gwangyoksi|Kyonggi-do|Kyongsang-bukto|Kyongsang-namdo|Pusan-gwangyoksi|Soul-t'ukpyolsi|Taegu-gwangyoksi|Taejon-gwangyoksi|Ulsan-gwangyoksi"
  "Al 'Asimah|Al Ahmadi|Al Farwaniyah|Al Jahra'|Hawalli"
  "Batken Oblasty|Bishkek Shaary|Chuy Oblasty (Bishkek)|Jalal-Abad Oblasty|Naryn Oblasty|Osh Oblasty|Talas Oblasty|Ysyk-Kol Oblasty (Karakol)"
  "Attapu|Bokeo|Bolikhamxai|Champasak|Houaphan|Khammouan|Louangnamtha|Louangphabang|Oudomxai|Phongsali|Salavan|Savannakhet|Viangchan|Viangchan|Xaignabouli|Xaisomboun|Xekong|Xiangkhoang"
  "Aizkraukles Rajons|Aluksnes Rajons|Balvu Rajons|Bauskas Rajons|Cesu Rajons|Daugavpils|Daugavpils Rajons|Dobeles Rajons|Gulbenes Rajons|Jekabpils Rajons|Jelgava|Jelgavas Rajons|Jurmala|Kraslavas Rajons|Kuldigas Rajons|Leipaja|Liepajas Rajons|Limbazu Rajons|Ludzas Rajons|Madonas Rajons|Ogres Rajons|Preilu Rajons|Rezekne|Rezeknes Rajons|Riga|Rigas Rajons|Saldus Rajons|Talsu Rajons|Tukuma Rajons|Valkas Rajons|Valmieras Rajons|Ventspils|Ventspils Rajons"
  "Beyrouth|Ech Chimal|Ej Jnoub|El Bekaa|Jabal Loubnane"
  "Berea|Butha-Buthe|Leribe|Mafeteng|Maseru|Mohales Hoek|Mokhotlong|Qacha's Nek|Quthing|Thaba-Tseka"
  "Bomi|Bong|Grand Bassa|Grand Cape Mount|Grand Gedeh|Grand Kru|Lofa|Margibi|Maryland|Montserrado|Nimba|River Cess|Sinoe"
  "Ajdabiya|Al 'Aziziyah|Al Fatih|Al Jabal al Akhdar|Al Jufrah|Al Khums|Al Kufrah|An Nuqat al Khams|Ash Shati'|Awbari|Az Zawiyah|Banghazi|Darnah|Ghadamis|Gharyan|Misratah|Murzuq|Sabha|Sawfajjin|Surt|Tarabulus|Tarhunah|Tubruq|Yafran|Zlitan"
  "Balzers|Eschen|Gamprin|Mauren|Planken|Ruggell|Schaan|Schellenberg|Triesen|Triesenberg|Vaduz"
  "Akmenes Rajonas|Alytaus Rajonas|Alytus|Anyksciu Rajonas|Birstonas|Birzu Rajonas|Druskininkai|Ignalinos Rajonas|Jonavos Rajonas|Joniskio Rajonas|Jurbarko Rajonas|Kaisiadoriu Rajonas|Kaunas|Kauno Rajonas|Kedainiu Rajonas|Kelmes Rajonas|Klaipeda|Klaipedos Rajonas|Kretingos Rajonas|Kupiskio Rajonas|Lazdiju Rajonas|Marijampole|Marijampoles Rajonas|Mazeikiu Rajonas|Moletu Rajonas|Neringa Pakruojo Rajonas|Palanga|Panevezio Rajonas|Panevezys|Pasvalio Rajonas|Plunges Rajonas|Prienu Rajonas|Radviliskio Rajonas|Raseiniu Rajonas|Rokiskio Rajonas|Sakiu Rajonas|Salcininku Rajonas|Siauliai|Siauliu Rajonas|Silales Rajonas|Silutes Rajonas|Sirvintu Rajonas|Skuodo Rajonas|Svencioniu Rajonas|Taurages Rajonas|Telsiu Rajonas|Traku Rajonas|Ukmerges Rajonas|Utenos Rajonas|Varenos Rajonas|Vilkaviskio Rajonas|Vilniaus Rajonas|Vilnius|Zarasu Rajonas"
  "Diekirch|Grevenmacher|Luxembourg"
  "Macau"
  "Aracinovo|Bac|Belcista|Berovo|Bistrica|Bitola|Blatec|Bogdanci|Bogomila|Bogovinje|Bosilovo|Brvenica|Cair (Skopje)|Capari|Caska|Cegrane|Centar (Skopje)|Centar Zupa|Cesinovo|Cucer-Sandevo|Debar|Delcevo|Delogozdi|Demir Hisar|Demir Kapija|Dobrusevo|Dolna Banjica|Dolneni|Dorce Petrov (Skopje)|Drugovo|Dzepciste|Gazi Baba (Skopje)|Gevgelija|Gostivar|Gradsko|Ilinden|Izvor|Jegunovce|Kamenjane|Karbinci|Karpos (Skopje)|Kavadarci|Kicevo|Kisela Voda (Skopje)|Klecevce|Kocani|Konce|Kondovo|Konopiste|Kosel|Kratovo|Kriva Palanka|Krivogastani|Krusevo|Kuklis|Kukurecani|Kumanovo|Labunista|Lipkovo|Lozovo|Lukovo|Makedonska Kamenica|Makedonski Brod|Mavrovi Anovi|Meseista|Miravci|Mogila|Murtino|Negotino|Negotino-Poloska|Novaci|Novo Selo|Oblesevo|Ohrid|Orasac|Orizari|Oslomej|Pehcevo|Petrovec|Plasnia|Podares|Prilep|Probistip|Radovis|Rankovce|Resen|Rosoman|Rostusa|Samokov|Saraj|Sipkovica|Sopiste|Sopotnika|Srbinovo|Star Dojran|Staravina|Staro Nagoricane|Stip|Struga|Strumica|Studenicani|Suto Orizari (Skopje)|Sveti Nikole|Tearce|Tetovo|Topolcani|Valandovo|Vasilevo|Veles|Velesta|Vevcani|Vinica|Vitoliste|Vranestica|Vrapciste|Vratnica|Vrutok|Zajas|Zelenikovo|Zileno|Zitose|Zletovo|Zrnovci"
  "Antananarivo|Antsiranana|Fianarantsoa|Mahajanga|Toamasina|Toliara"
  "Balaka|Blantyre|Chikwawa|Chiradzulu|Chitipa|Dedza|Dowa|Karonga|Kasungu|Likoma|Lilongwe|Machinga (Kasupe)|Mangochi|Mchinji|Mulanje|Mwanza|Mzimba|Nkhata Bay|Nkhotakota|Nsanje|Ntcheu|Ntchisi|Phalombe|Rumphi|Salima|Thyolo|Zomba"
  "Johor|Kedah|Kelantan|Labuan|Melaka|Negeri Sembilan|Pahang|Perak|Perlis|Pulau Pinang|Sabah|Sarawak|Selangor|Terengganu|Wilayah Persekutuan"
  "Alifu|Baa|Dhaalu|Faafu|Gaafu Alifu|Gaafu Dhaalu|Gnaviyani|Haa Alifu|Haa Dhaalu|Kaafu|Laamu|Lhaviyani|Maale|Meemu|Noonu|Raa|Seenu|Shaviyani|Thaa|Vaavu"
  "Gao|Kayes|Kidal|Koulikoro|Mopti|Segou|Sikasso|Tombouctou"
  "Valletta"
  "Man, Isle of"
  "Ailinginae|Ailinglaplap|Ailuk|Arno|Aur|Bikar|Bikini|Bokak|Ebon|Enewetak|Erikub|Jabat|Jaluit|Jemo|Kili|Kwajalein|Lae|Lib|Likiep|Majuro|Maloelap|Mejit|Mili|Namorik|Namu|Rongelap|Rongrik|Toke|Ujae|Ujelang|Utirik|Wotho|Wotje"
  "Martinique"
  "Adrar|Assaba|Brakna|Dakhlet Nouadhibou|Gorgol|Guidimaka|Hodh Ech Chargui|Hodh El Gharbi|Inchiri|Nouakchott|Tagant|Tiris Zemmour|Trarza"
  "Agalega Islands|Black River|Cargados Carajos Shoals|Flacq|Grand Port|Moka|Pamplemousses|Plaines Wilhems|Port Louis|Riviere du Rempart|Rodrigues|Savanne"
  "Mayotte"
  "Aguascalientes|Baja California|Baja California Sur|Campeche|Chiapas|Chihuahua|Coahuila de Zaragoza|Colima|Distrito Federal|Durango|Guanajuato|Guerrero|Hidalgo|Jalisco|Mexico|Michoacan de Ocampo|Morelos|Nayarit|Nuevo Leon|Oaxaca|Puebla|Queretaro de Arteaga|Quintana Roo|San Luis Potosi|Sinaloa|Sonora|Tabasco|Tamaulipas|Tlaxcala|Veracruz-Llave|Yucatan|Zacatecas"
  "Chuuk (Truk)|Kosrae|Pohnpei|Yap"
  "Midway Islands"
  "Balti|Cahul|Chisinau|Chisinau|Dubasari|Edinet|Gagauzia|Lapusna|Orhei|Soroca|Tighina|Ungheni"
  "Fontvieille|La Condamine|Monaco-Ville|Monte-Carlo"
  "Arhangay|Bayan-Olgiy|Bayanhongor|Bulgan|Darhan|Dornod|Dornogovi|Dundgovi|Dzavhan|Erdenet|Govi-Altay|Hentiy|Hovd|Hovsgol|Omnogovi|Ovorhangay|Selenge|Suhbaatar|Tov|Ulaanbaatar|Uvs"
  "Saint Anthony|Saint Georges|Saint Peter's"
  "Agadir|Al Hoceima|Azilal|Ben Slimane|Beni Mellal|Boulemane|Casablanca|Chaouen|El Jadida|El Kelaa des Srarhna|Er Rachidia|Essaouira|Fes|Figuig|Guelmim|Ifrane|Kenitra|Khemisset|Khenifra|Khouribga|Laayoune|Larache|Marrakech|Meknes|Nador|Ouarzazate|Oujda|Rabat-Sale|Safi|Settat|Sidi Kacem|Tan-Tan|Tanger|Taounate|Taroudannt|Tata|Taza|Tetouan|Tiznit"
  "Cabo Delgado|Gaza|Inhambane|Manica|Maputo|Nampula|Niassa|Sofala|Tete|Zambezia"
  "Caprivi|Erongo|Hardap|Karas|Khomas|Kunene|Ohangwena|Okavango|Omaheke|Omusati|Oshana|Oshikoto|Otjozondjupa"
  "Aiwo|Anabar|Anetan|Anibare|Baiti|Boe|Buada|Denigomodu|Ewa|Ijuw|Meneng|Nibok|Uaboe|Yaren"
  "Bagmati|Bheri|Dhawalagiri|Gandaki|Janakpur|Karnali|Kosi|Lumbini|Mahakali|Mechi|Narayani|Rapti|Sagarmatha|Seti"
  "Drenthe|Flevoland|Friesland|Gelderland|Groningen|Limburg|Noord-Brabant|Noord-Holland|Overijssel|Utrecht|Zeeland|Zuid-Holland"
  "Netherlands Antilles"
  "Iles Loyaute|Nord|Sud"
  "Akaroa|Amuri|Ashburton|Bay of Islands|Bruce|Buller|Chatham Islands|Cheviot|Clifton|Clutha|Cook|Dannevirke|Egmont|Eketahuna|Ellesmere|Eltham|Eyre|Featherston|Franklin|Golden Bay|Great Barrier Island|Grey|Hauraki Plains|Hawera|Hawke's Bay|Heathcote|Hikurangi|Hobson|Hokianga|Horowhenua|Hurunui|Hutt|Inangahua|Inglewood|Kaikoura|Kairanga|Kiwitea|Lake|Mackenzie|Malvern|Manaia|Manawatu|Mangonui|Maniototo|Marlborough|Masterton|Matamata|Mount Herbert|Ohinemuri|Opotiki|Oroua|Otamatea|Otorohanga|Oxford|Pahiatua|Paparua|Patea|Piako|Pohangina|Raglan|Rangiora|Rangitikei|Rodney|Rotorua|Runanga|Saint Kilda|Silverpeaks|Southland|Stewart Island|Stratford|Strathallan|Taranaki|Taumarunui|Taupo|Tauranga|Thames-Coromandel|Tuapeka|Vincent|Waiapu|Waiheke|Waihemo|Waikato|Waikohu|Waimairi|Waimarino|Waimate|Waimate West|Waimea|Waipa|Waipawa|Waipukurau|Wairarapa South|Wairewa|Wairoa|Waitaki|Waitomo|Waitotara|Wallace|Wanganui|Waverley|Westland|Whakatane|Whangarei|Whangaroa|Woodville"
  "Atlantico Norte|Atlantico Sur|Boaco|Carazo|Chinandega|Chontales|Esteli|Granada|Jinotega|Leon|Madriz|Managua|Masaya|Matagalpa|Nueva Segovia|Rio San Juan|Rivas"
  "Agadez|Diffa|Dosso|Maradi|Niamey|Tahoua|Tillaberi|Zinder"
  "Abia|Abuja Federal Capital Territory|Adamawa|Akwa Ibom|Anambra|Bauchi|Bayelsa|Benue|Borno|Cross River|Delta|Ebonyi|Edo|Ekiti|Enugu|Gombe|Imo|Jigawa|Kaduna|Kano|Katsina|Kebbi|Kogi|Kwara|Lagos|Nassarawa|Niger|Ogun|Ondo|Osun|Oyo|Plateau|Rivers|Sokoto|Taraba|Yobe|Zamfara"
  "Niue"
  "Norfolk Island"
  "Northern Islands|Rota|Saipan|Tinian"
  "Akershus|Aust-Agder|Buskerud|Finnmark|Hedmark|Hordaland|More og Romsdal|Nord-Trondelag|Nordland|Oppland|Oslo|Ostfold|Rogaland|Sogn og Fjordane|Sor-Trondelag|Telemark|Troms|Vest-Agder|Vestfold"
  "Ad Dakhiliyah|Al Batinah|Al Wusta|Ash Sharqiyah|Az Zahirah|Masqat|Musandam|Zufar"
  "Balochistan|Federally Administered Tribal Areas|Islamabad Capital Territory|North-West Frontier Province|Punjab|Sindh"
  "Aimeliik|Airai|Angaur|Hatobohei|Kayangel|Koror|Melekeok|Ngaraard|Ngarchelong|Ngardmau|Ngatpang|Ngchesar|Ngeremlengui|Ngiwal|Palau Island|Peleliu|Sonsoral|Tobi"
  "Bocas del Toro|Chiriqui|Cocle|Colon|Darien|Herrera|Los Santos|Panama|San Blas|Veraguas"
  "Bougainville|Central|Chimbu|East New Britain|East Sepik|Eastern Highlands|Enga|Gulf|Madang|Manus|Milne Bay|Morobe|National Capital|New Ireland|Northern|Sandaun|Southern Highlands|West New Britain|Western|Western Highlands"
  "Alto Paraguay|Alto Parana|Amambay|Asuncion (city)|Boqueron|Caaguazu|Caazapa|Canindeyu|Central|Concepcion|Cordillera|Guaira|Itapua|Misiones|Neembucu|Paraguari|Presidente Hayes|San Pedro"
  "Amazonas|Ancash|Apurimac|Arequipa|Ayacucho|Cajamarca|Callao|Cusco|Huancavelica|Huanuco|Ica|Junin|La Libertad|Lambayeque|Lima|Loreto|Madre de Dios|Moquegua|Pasco|Piura|Puno|San Martin|Tacna|Tumbes|Ucayali"
  "Abra|Agusan del Norte|Agusan del Sur|Aklan|Albay|Angeles|Antique|Aurora|Bacolod|Bago|Baguio|Bais|Basilan|Basilan City|Bataan|Batanes|Batangas|Batangas City|Benguet|Bohol|Bukidnon|Bulacan|Butuan|Cabanatuan|Cadiz|Cagayan|Cagayan de Oro|Calbayog|Caloocan|Camarines Norte|Camarines Sur|Camiguin|Canlaon|Capiz|Catanduanes|Cavite|Cavite City|Cebu|Cebu City|Cotabato|Dagupan|Danao|Dapitan|Davao City Davao|Davao del Sur|Davao Oriental|Dipolog|Dumaguete|Eastern Samar|General Santos|Gingoog|Ifugao|Iligan|Ilocos Norte|Ilocos Sur|Iloilo|Iloilo City|Iriga|Isabela|Kalinga-Apayao|La Carlota|La Union|Laguna|Lanao del Norte|Lanao del Sur|Laoag|Lapu-Lapu|Legaspi|Leyte|Lipa|Lucena|Maguindanao|Mandaue|Manila|Marawi|Marinduque|Masbate|Mindoro Occidental|Mindoro Oriental|Misamis Occidental|Misamis Oriental|Mountain|Naga|Negros Occidental|Negros Oriental|North Cotabato|Northern Samar|Nueva Ecija|Nueva Vizcaya|Olongapo|Ormoc|Oroquieta|Ozamis|Pagadian|Palawan|Palayan|Pampanga|Pangasinan|Pasay|Puerto Princesa|Quezon|Quezon City|Quirino|Rizal|Romblon|Roxas|Samar|San Carlos (in Negros Occidental)|San Carlos (in Pangasinan)|San Jose|San Pablo|Silay|Siquijor|Sorsogon|South Cotabato|Southern Leyte|Sultan Kudarat|Sulu|Surigao|Surigao del Norte|Surigao del Sur|Tacloban|Tagaytay|Tagbilaran|Tangub|Tarlac|Tawitawi|Toledo|Trece Martires|Zambales|Zamboanga|Zamboanga del Norte|Zamboanga del Sur"
  "Pitcaim Islands"
  "Dolnoslaskie|Kujawsko-Pomorskie|Lodzkie|Lubelskie|Lubuskie|Malopolskie|Mazowieckie|Opolskie|Podkarpackie|Podlaskie|Pomorskie|Slaskie|Swietokrzyskie|Warminsko-Mazurskie|Wielkopolskie|Zachodniopomorskie"
  "Acores (Azores)|Aveiro|Beja|Braga|Braganca|Castelo Branco|Coimbra|Evora|Faro|Guarda|Leiria|Lisboa|Madeira|Portalegre|Porto|Santarem|Setubal|Viana do Castelo|Vila Real|Viseu"
  "Adjuntas|Aguada|Aguadilla|Aguas Buenas|Aibonito|Anasco|Arecibo|Arroyo|Barceloneta|Barranquitas|Bayamon|Cabo Rojo|Caguas|Camuy|Canovanas|Carolina|Catano|Cayey|Ceiba|Ciales|Cidra|Coamo|Comerio|Corozal|Culebra|Dorado|Fajardo|Florida|Guanica|Guayama|Guayanilla|Guaynabo|Gurabo|Hatillo|Hormigueros|Humacao|Isabela|Jayuya|Juana Diaz|Juncos|Lajas|Lares|Las Marias|Las Piedras|Loiza|Luquillo|Manati|Maricao|Maunabo|Mayaguez|Moca|Morovis|Naguabo|Naranjito|Orocovis|Patillas|Penuelas|Ponce|Quebradillas|Rincon|Rio Grande|Sabana Grande|Salinas|San German|San Juan|San Lorenzo|San Sebastian|Santa Isabel|Toa Alta|Toa Baja|Trujillo Alto|Utuado|Vega Alta|Vega Baja|Vieques|Villalba|Yabucoa|Yauco"
  "Ad Dawhah|Al Ghuwayriyah|Al Jumayliyah|Al Khawr|Al Wakrah|Ar Rayyan|Jarayan al Batinah|Madinat ash Shamal|Umm Salal"
  "Reunion"
  "Alba|Arad|Arges|Bacau|Bihor|Bistrita-Nasaud|Botosani|Braila|Brasov|Bucuresti|Buzau|Calarasi|Caras-Severin|Cluj|Constanta|Covasna|Dimbovita|Dolj|Galati|Giurgiu|Gorj|Harghita|Hunedoara|Ialomita|Iasi|Maramures|Mehedinti|Mures|Neamt|Olt|Prahova|Salaj|Satu Mare|Sibiu|Suceava|Teleorman|Timis|Tulcea|Vaslui|Vilcea|Vrancea"
  "Adygeya (Maykop)|Aginskiy Buryatskiy (Aginskoye)|Altay (Gorno-Altaysk)|Altayskiy (Barnaul)|Amurskaya (Blagoveshchensk)|Arkhangel'skaya|Astrakhanskaya|Bashkortostan (Ufa)|Belgorodskaya|Bryanskaya|Buryatiya (Ulan-Ude)|Chechnya (Groznyy)|Chelyabinskaya|Chitinskaya|Chukotskiy (Anadyr')|Chuvashiya (Cheboksary)|Dagestan (Makhachkala)|Evenkiyskiy (Tura)|Ingushetiya (Nazran')|Irkutskaya|Ivanovskaya|Kabardino-Balkariya (Nal'chik)|Kaliningradskaya|Kalmykiya (Elista)|Kaluzhskaya|Kamchatskaya (Petropavlovsk-Kamchatskiy)|Karachayevo-Cherkesiya (Cherkessk)|Kareliya (Petrozavodsk)|Kemerovskaya|Khabarovskiy|Khakasiya (Abakan)|Khanty-Mansiyskiy (Khanty-Mansiysk)|Kirovskaya|Komi (Syktyvkar)|Komi-Permyatskiy (Kudymkar)|Koryakskiy (Palana)|Kostromskaya|Krasnodarskiy|Krasnoyarskiy|Kurganskaya|Kurskaya|Leningradskaya|Lipetskaya|Magadanskaya|Mariy-El (Yoshkar-Ola)|Mordoviya (Saransk)|Moskovskaya|Moskva (Moscow)|Murmanskaya|Nenetskiy (Nar'yan-Mar)|Nizhegorodskaya|Novgorodskaya|Novosibirskaya|Omskaya|Orenburgskaya|Orlovskaya (Orel)|Penzenskaya|Permskaya|Primorskiy (Vladivostok)|Pskovskaya|Rostovskaya|Ryazanskaya|Sakha (Yakutsk)|Sakhalinskaya (Yuzhno-Sakhalinsk)|Samarskaya|Sankt-Peterburg (Saint Petersburg)|Saratovskaya|Severnaya Osetiya-Alaniya [North Ossetia] (Vladikavkaz)|Smolenskaya|Stavropol'skiy|Sverdlovskaya (Yekaterinburg)|Tambovskaya|Tatarstan (Kazan')|Taymyrskiy (Dudinka)|Tomskaya|Tul'skaya|Tverskaya|Tyumenskaya|Tyva (Kyzyl)|Udmurtiya (Izhevsk)|Ul'yanovskaya|Ust'-Ordynskiy Buryatskiy (Ust'-Ordynskiy)|Vladimirskaya|Volgogradskaya|Vologodskaya|Voronezhskaya|Yamalo-Nenetskiy (Salekhard)|Yaroslavskaya|Yevreyskaya"
  "Butare|Byumba|Cyangugu|Gikongoro|Gisenyi|Gitarama|Kibungo|Kibuye|Kigali Rurale|Kigali-ville|Ruhengeri|Umutara"
  "Ascension|Saint Helena|Tristan da Cunha"
  "Christ Church Nichola Town|Saint Anne Sandy Point|Saint George Basseterre|Saint George Gingerland|Saint James Windward|Saint John Capisterre|Saint John Figtree|Saint Mary Cayon|Saint Paul Capisterre|Saint Paul Charlestown|Saint Peter Basseterre|Saint Thomas Lowland|Saint Thomas Middle Island|Trinity Palmetto Point"
  "Anse-la-Raye|Castries|Choiseul|Dauphin|Dennery|Gros Islet|Laborie|Micoud|Praslin|Soufriere|Vieux Fort"
  "Miquelon|Saint Pierre"
  "Charlotte|Grenadines|Saint Andrew|Saint David|Saint George|Saint Patrick"
  "A'ana|Aiga-i-le-Tai|Atua|Fa'asaleleaga|Gaga'emauga|Gagaifomauga|Palauli|Satupa'itea|Tuamasaga|Va'a-o-Fonoti|Vaisigano"
  "Acquaviva|Borgo Maggiore|Chiesanuova|Domagnano|Faetano|Fiorentino|Monte Giardino|San Marino|Serravalle"
  "Principe|Sao Tome"
  "'Asir|Al Bahah|Al Hudud ash Shamaliyah|Al Jawf|Al Madinah|Al Qasim|Ar Riyad|Ash Sharqiyah (Eastern Province)|Ha'il|Jizan|Makkah|Najran|Tabuk"
  "Aberdeen City|Aberdeenshire|Angus|Argyll and Bute|City of Edinburgh|Clackmannanshire|Dumfries and Galloway|Dundee City|East Ayrshire|East Dunbartonshire|East Lothian|East Renfrewshire|Eilean Siar (Western Isles)|Falkirk|Fife|Glasgow City|Highland|Inverclyde|Midlothian|Moray|North Ayrshire|North Lanarkshire|Orkney Islands|Perth and Kinross|Renfrewshire|Shetland Islands|South Ayrshire|South Lanarkshire|Stirling|The Scottish Borders|West Dunbartonshire|West Lothian"
  "Dakar|Diourbel|Fatick|Kaolack|Kolda|Louga|Saint-Louis|Tambacounda|Thies|Ziguinchor"
  "Anse aux Pins|Anse Boileau|Anse Etoile|Anse Louis|Anse Royale|Baie Lazare|Baie Sainte Anne|Beau Vallon|Bel Air|Bel Ombre|Cascade|Glacis|Grand' Anse (on Mahe)|Grand' Anse (on Praslin)|La Digue|La Riviere Anglaise|Mont Buxton|Mont Fleuri|Plaisance|Pointe La Rue|Port Glaud|Saint Louis|Takamaka"
  "Eastern|Northern|Southern|Western"
  "Singapore"
  "Banskobystricky|Bratislavsky|Kosicky|Nitriansky|Presovsky|Trenciansky|Trnavsky|Zilinsky"
  "Ajdovscina|Beltinci|Bled|Bohinj|Borovnica|Bovec|Brda|Brezice|Brezovica|Cankova-Tisina|Celje|Cerklje na Gorenjskem|Cerknica|Cerkno|Crensovci|Crna na Koroskem|Crnomelj|Destrnik-Trnovska Vas|Divaca|Dobrepolje|Dobrova-Horjul-Polhov Gradec|Dol pri Ljubljani|Domzale|Dornava|Dravograd|Duplek|Gorenja Vas-Poljane|Gorisnica|Gornja Radgona|Gornji Grad|Gornji Petrovci|Grosuplje|Hodos Salovci|Hrastnik|Hrpelje-Kozina|Idrija|Ig|Ilirska Bistrica|Ivancna Gorica|Izola|Jesenice|Jursinci|Kamnik|Kanal|Kidricevo|Kobarid|Kobilje|Kocevje|Komen|Koper|Kozje|Kranj|Kranjska Gora|Krsko|Kungota|Kuzma|Lasko|Lenart|Lendava|Litija|Ljubljana|Ljubno|Ljutomer|Logatec|Loska Dolina|Loski Potok|Luce|Lukovica|Majsperk|Maribor|Medvode|Menges|Metlika|Mezica|Miren-Kostanjevica|Mislinja|Moravce|Moravske Toplice|Mozirje|Murska Sobota|Muta|Naklo|Nazarje|Nova Gorica|Novo Mesto|Odranci|Ormoz|Osilnica|Pesnica|Piran|Pivka|Podcetrtek|Podvelka-Ribnica|Postojna|Preddvor|Ptuj|Puconci|Race-Fram|Radece|Radenci|Radlje ob Dravi|Radovljica|Ravne-Prevalje|Ribnica|Rogasevci|Rogaska Slatina|Rogatec|Ruse|Semic|Sencur|Sentilj|Sentjernej|Sentjur pri Celju|Sevnica|Sezana|Skocjan|Skofja Loka|Skofljica|Slovenj Gradec|Slovenska Bistrica|Slovenske Konjice|Smarje pri Jelsah|Smartno ob Paki|Sostanj|Starse|Store|Sveti Jurij|Tolmin|Trbovlje|Trebnje|Trzic|Turnisce|Velenje|Velike Lasce|Videm|Vipava|Vitanje|Vodice|Vojnik|Vrhnika|Vuzenica|Zagorje ob Savi|Zalec|Zavrc|Zelezniki|Ziri|Zrece"
  "Bellona|Central|Choiseul (Lauru)|Guadalcanal|Honiara|Isabel|Makira|Malaita|Rennell|Temotu|Western"
  "Awdal|Bakool|Banaadir|Bari|Bay|Galguduud|Gedo|Hiiraan|Jubbada Dhexe|Jubbada Hoose|Mudug|Nugaal|Sanaag|Shabeellaha Dhexe|Shabeellaha Hoose|Sool|Togdheer|Woqooyi Galbeed"
  "Eastern Cape|Free State|Gauteng|KwaZulu-Natal|Mpumalanga|North-West|Northern Cape|Northern Province|Western Cape"
  "Bird Island|Bristol Island|Clerke Rocks|Montagu Island|Saunders Island|South Georgia|Southern Thule|Traversay Islands"
  "Andalucia|Aragon|Asturias|Baleares (Balearic Islands)|Canarias (Canary Islands)|Cantabria|Castilla y Leon|Castilla-La Mancha|Cataluna|Ceuta|Communidad Valencian|Extremadura|Galicia|Islas Chafarinas|La Rioja|Madrid|Melilla|Murcia|Navarra|Pais Vasco (Basque Country)|Penon de Alhucemas|Penon de Velez de la Gomera"
  "Spratly Islands"
  "Central|Eastern|North Central|North Eastern|North Western|Northern|Sabaragamuwa|Southern|Uva|Western"
  "A'ali an Nil|Al Bahr al Ahmar|Al Buhayrat|Al Jazirah|Al Khartum|Al Qadarif|Al Wahdah|An Nil al Abyad|An Nil al Azraq|Ash Shamaliyah|Bahr al Jabal|Gharb al Istiwa'iyah|Gharb Bahr al Ghazal|Gharb Darfur|Gharb Kurdufan|Janub Darfur|Janub Kurdufan|Junqali|Kassala|Nahr an Nil|Shamal Bahr al Ghazal|Shamal Darfur|Shamal Kurdufan|Sharq al Istiwa'iyah|Sinnar|Warab"
  "Brokopondo|Commewijne|Coronie|Marowijne|Nickerie|Para|Paramaribo|Saramacca|Sipaliwini|Wanica"
  "Barentsoya|Bjornoya|Edgeoya|Hopen|Kvitoya|Nordaustandet|Prins Karls Forland|Spitsbergen"
  "Hhohho|Lubombo|Manzini|Shiselweni"
  "Blekinge|Dalarnas|Gavleborgs|Gotlands|Hallands|Jamtlands|Jonkopings|Kalmar|Kronobergs|Norrbottens|Orebro|Ostergotlands|Skane|Sodermanlands|Stockholms|Uppsala|Varmlands|Vasterbottens|Vasternorrlands|Vastmanlands|Vastra Gotalands"
  "Aargau|Ausser-Rhoden|Basel-Landschaft|Basel-Stadt|Bern|Fribourg|Geneve|Glarus|Graubunden|Inner-Rhoden|Jura|Luzern|Neuchatel|Nidwalden|Obwalden|Sankt Gallen|Schaffhausen|Schwyz|Solothurn|Thurgau|Ticino|Uri|Valais|Vaud|Zug|Zurich"
  "Al Hasakah|Al Ladhiqiyah|Al Qunaytirah|Ar Raqqah|As Suwayda'|Dar'a|Dayr az Zawr|Dimashq|Halab|Hamah|Hims|Idlib|Rif Dimashq|Tartus"
  "Chang-hua|Chi-lung|Chia-i|Chia-i|Chung-hsing-hsin-ts'un|Hsin-chu|Hsin-chu|Hua-lien|I-lan|Kao-hsiung|Kao-hsiung|Miao-li|Nan-t'ou|P'eng-hu|P'ing-tung|T'ai-chung|T'ai-chung|T'ai-nan|T'ai-nan|T'ai-pei|T'ai-pei|T'ai-tung|T'ao-yuan|Yun-lin"
  "Viloyati Khatlon|Viloyati Leninobod|Viloyati Mukhtori Kuhistoni Badakhshon"
  "Arusha|Dar es Salaam|Dodoma|Iringa|Kagera|Kigoma|Kilimanjaro|Lindi|Mara|Mbeya|Morogoro|Mtwara|Mwanza|Pemba North|Pemba South|Pwani|Rukwa|Ruvuma|Shinyanga|Singida|Tabora|Tanga|Zanzibar Central/South|Zanzibar North|Zanzibar Urban/West"
  "Amnat Charoen|Ang Thong|Buriram|Chachoengsao|Chai Nat|Chaiyaphum|Chanthaburi|Chiang Mai|Chiang Rai|Chon Buri|Chumphon|Kalasin|Kamphaeng Phet|Kanchanaburi|Khon Kaen|Krabi|Krung Thep Mahanakhon (Bangkok)|Lampang|Lamphun|Loei|Lop Buri|Mae Hong Son|Maha Sarakham|Mukdahan|Nakhon Nayok|Nakhon Pathom|Nakhon Phanom|Nakhon Ratchasima|Nakhon Sawan|Nakhon Si Thammarat|Nan|Narathiwat|Nong Bua Lamphu|Nong Khai|Nonthaburi|Pathum Thani|Pattani|Phangnga|Phatthalung|Phayao|Phetchabun|Phetchaburi|Phichit|Phitsanulok|Phra Nakhon Si Ayutthaya|Phrae|Phuket|Prachin Buri|Prachuap Khiri Khan|Ranong|Ratchaburi|Rayong|Roi Et|Sa Kaeo|Sakon Nakhon|Samut Prakan|Samut Sakhon|Samut Songkhram|Sara Buri|Satun|Sing Buri|Sisaket|Songkhla|Sukhothai|Suphan Buri|Surat Thani|Surin|Tak|Trang|Trat|Ubon Ratchathani|Udon Thani|Uthai Thani|Uttaradit|Yala|Yasothon"
  "Tobago"
  "De La Kara|Des Plateaux|Des Savanes|Du Centre|Maritime"
  "Atafu|Fakaofo|Nukunonu"
  "Ha'apai|Tongatapu|Vava'u"
  "Arima|Caroni|Mayaro|Nariva|Port-of-Spain|Saint Andrew|Saint David|Saint George|Saint Patrick|San Fernando|Victoria"
  "Ariana|Beja|Ben Arous|Bizerte|El Kef|Gabes|Gafsa|Jendouba|Kairouan|Kasserine|Kebili|Mahdia|Medenine|Monastir|Nabeul|Sfax|Sidi Bou Zid|Siliana|Sousse|Tataouine|Tozeur|Tunis|Zaghouan"
  "Adana|Adiyaman|Afyon|Agri|Aksaray|Amasya|Ankara|Antalya|Ardahan|Artvin|Aydin|Balikesir|Bartin|Batman|Bayburt|Bilecik|Bingol|Bitlis|Bolu|Burdur|Bursa|Canakkale|Cankiri|Corum|Denizli|Diyarbakir|Duzce|Edirne|Elazig|Erzincan|Erzurum|Eskisehir|Gaziantep|Giresun|Gumushane|Hakkari|Hatay|Icel|Igdir|Isparta|Istanbul|Izmir|Kahramanmaras|Karabuk|Karaman|Kars|Kastamonu|Kayseri|Kilis|Kirikkale|Kirklareli|Kirsehir|Kocaeli|Konya|Kutahya|Malatya|Manisa|Mardin|Mugla|Mus|Nevsehir|Nigde|Ordu|Osmaniye|Rize|Sakarya|Samsun|Sanliurfa|Siirt|Sinop|Sirnak|Sivas|Tekirdag|Tokat|Trabzon|Tunceli|Usak|Van|Yalova|Yozgat|Zonguldak"
  "Ahal Welayaty|Balkan Welayaty|Dashhowuz Welayaty|Lebap Welayaty|Mary Welayaty"
  "Tuvalu"
  "Adjumani|Apac|Arua|Bugiri|Bundibugyo|Bushenyi|Busia|Gulu|Hoima|Iganga|Jinja|Kabale|Kabarole|Kalangala|Kampala|Kamuli|Kapchorwa|Kasese|Katakwi|Kibale|Kiboga|Kisoro|Kitgum|Kotido|Kumi|Lira|Luwero|Masaka|Masindi|Mbale|Mbarara|Moroto|Moyo|Mpigi|Mubende|Mukono|Nakasongola|Nebbi|Ntungamo|Pallisa|Rakai|Rukungiri|Sembabule|Soroti|Tororo"
  "Avtonomna Respublika Krym (Simferopol')|Cherkas'ka (Cherkasy)|Chernihivs'ka (Chernihiv)|Chernivets'ka (Chernivtsi)|Dnipropetrovs'ka (Dnipropetrovs'k)|Donets'ka (Donets'k)|Ivano-Frankivs'ka (Ivano-Frankivs'k)|Kharkivs'ka (Kharkiv)|Khersons'ka (Kherson)|Khmel'nyts'ka (Khmel'nyts'kyy)|Kirovohrads'ka (Kirovohrad)|Kyyiv|Kyyivs'ka (Kiev)|L'vivs'ka (L'viv)|Luhans'ka (Luhans'k)|Mykolayivs'ka (Mykolayiv)|Odes'ka (Odesa)|Poltavs'ka (Poltava)|Rivnens'ka (Rivne)|Sevastopol'|Sums'ka (Sumy)|Ternopil's'ka (Ternopil')|Vinnyts'ka (Vinnytsya)|Volyns'ka (Luts'k)|Zakarpats'ka (Uzhhorod)|Zaporiz'ka (Zaporizhzhya)|Zhytomyrs'ka (Zhytomyr)"
  "'Ajman|Abu Zaby (Abu Dhabi)|Al Fujayrah|Ash Shariqah (Sharjah)|Dubayy (Dubai)|Ra's al Khaymah|Umm al Qaywayn"
  "Barking and Dagenham|Barnet|Barnsley|Bath and North East Somerset|Bedfordshire|Bexley|Birmingham|Blackburn with Darwen|Blackpool|Bolton|Bournemouth|Bracknell Forest|Bradford|Brent|Brighton and Hove|Bromley|Buckinghamshire|Bury|Calderdale|Cambridgeshire|Camden|Cheshire|City of Bristol|City of Kingston upon Hull|City of London|Cornwall|Coventry|Croydon|Cumbria|Darlington|Derby|Derbyshire|Devon|Doncaster|Dorset|Dudley|Durham|Ealing|East Riding of Yorkshire|East Sussex|Enfield|Essex|Gateshead|Gloucestershire|Greenwich|Hackney|Halton|Hammersmith and Fulham|Hampshire|Haringey|Harrow|Hartlepool|Havering|Herefordshire|Hertfordshire|Hillingdon|Hounslow|Isle of Wight|Islington|Kensington and Chelsea|Kent|Kingston upon Thames|Kirklees|Knowsley|Lambeth|Lancashire|Leeds|Leicester|Leicestershire|Lewisham|Lincolnshire|Liverpool|Luton|Manchester|Medway|Merton|Middlesbrough|Milton Keynes|Newcastle upon Tyne|Newham|Norfolk|North East Lincolnshire|North Lincolnshire|North Somerset|North Tyneside|North Yorkshire|Northamptonshire|Northumberland|Nottingham|Nottinghamshire|Oldham|Oxfordshire|Peterborough|Plymouth|Poole|Portsmouth|Reading|Redbridge|Redcar and Cleveland|Richmond upon Thames|Rochdale|Rotherham|Rutland|Salford|Sandwell|Sefton|Sheffield|Shropshire|Slough|Solihull|Somerset|South Gloucestershire|South Tyneside|Southampton|Southend-on-Sea|Southwark|St. Helens|Staffordshire|Stockport|Stockton-on-Tees|Stoke-on-Trent|Suffolk|Sunderland|Surrey|Sutton|Swindon|Tameside|Telford and Wrekin|Thurrock|Torbay|Tower Hamlets|Trafford|Wakefield|Walsall|Waltham Forest|Wandsworth|Warrington|Warwickshire|West Berkshire|West Sussex|Westminster|Wigan|Wiltshire|Windsor and Maidenhead|Wirral|Wokingham|Wolverhampton|Worcestershire|York"
  "Artigas|Canelones|Cerro Largo|Colonia|Durazno|Flores|Florida|Lavalleja|Maldonado|Montevideo|Paysandu|Rio Negro|Rivera|Rocha|Salto|San Jose|Soriano|Tacuarembo|Treinta y Tres"
  "Alabama|Alaska|Arizona|Arkansas|California|Colorado|Connecticut|Delaware|District of Columbia|Florida|Georgia|Hawaii|Idaho|Illinois|Indiana|Iowa|Kansas|Kentucky|Louisiana|Maine|Maryland|Massachusetts|Michigan|Minnesota|Mississippi|Missouri|Montana|Nebraska|Nevada|New Hampshire|New Jersey|New Mexico|New York|North Carolina|North Dakota|Ohio|Oklahoma|Oregon|Pennsylvania|Rhode Island|South Carolina|South Dakota|Tennessee|Texas|Utah|Vermont|Virginia|Washington|West Virginia|Wisconsin|Wyoming"
  "Andijon Wiloyati|Bukhoro Wiloyati|Farghona Wiloyati|Jizzakh Wiloyati|Khorazm Wiloyati (Urganch)|Namangan Wiloyati|Nawoiy Wiloyati|Qashqadaryo Wiloyati (Qarshi)|Qoraqalpoghiston (Nukus)|Samarqand Wiloyati|Sirdaryo Wiloyati (Guliston)|Surkhondaryo Wiloyati (Termiz)|Toshkent Shahri|Toshkent Wiloyati"
  "Malampa|Penama|Sanma|Shefa|Tafea|Torba"
  "Amazonas|Anzoategui|Apure|Aragua|Barinas|Bolivar|Carabobo|Cojedes|Delta Amacuro|Dependencias Federales|Distrito Federal|Falcon|Guarico|Lara|Merida|Miranda|Monagas|Nueva Esparta|Portuguesa|Sucre|Tachira|Trujillo|Vargas|Yaracuy|Zulia"
  "An Giang|Ba Ria-Vung Tau|Bac Giang|Bac Kan|Bac Lieu|Bac Ninh|Ben Tre|Binh Dinh|Binh Duong|Binh Phuoc|Binh Thuan|Ca Mau|Can Tho|Cao Bang|Da Nang|Dac Lak|Dong Nai|Dong Thap|Gia Lai|Ha Giang|Ha Nam|Ha Noi|Ha Tay|Ha Tinh|Hai Duong|Hai Phong|Ho Chi Minh|Hoa Binh|Hung Yen|Khanh Hoa|Kien Giang|Kon Tum|Lai Chau|Lam Dong|Lang Son|Lao Cai|Long An|Nam Dinh|Nghe An|Ninh Binh|Ninh Thuan|Phu Tho|Phu Yen|Quang Binh|Quang Nam|Quang Ngai|Quang Ninh|Quang Tri|Soc Trang|Son La|Tay Ninh|Thai Binh|Thai Nguyen|Thanh Hoa|Thua Thien-Hue|Tien Giang|Tra Vinh|Tuyen Quang|Vinh Long|Vinh Phuc|Yen Bai"
  "Saint Croix|Saint John|Saint Thomas"
  "Blaenau Gwent|Bridgend|Caerphilly|Cardiff|Carmarthenshire|Ceredigion|Conwy|Denbighshire|Flintshire|Gwynedd|Isle of Anglesey|Merthyr Tydfil|Monmouthshire|Neath Port Talbot|Newport|Pembrokeshire|Powys|Rhondda Cynon Taff|Swansea|The Vale of Glamorgan|Torfaen|Wrexham"
  "Alo|Sigave|Wallis"
  "West Bank"
  "Western Sahara"
  "'Adan|'Ataq|Abyan|Al Bayda'|Al Hudaydah|Al Jawf|Al Mahrah|Al Mahwit|Dhamar|Hadhramawt|Hajjah|Ibb|Lahij|Ma'rib|Sa'dah|San'a'|Ta'izz"
  "Kosovo|Montenegro|Serbia|Vojvodina"
  "Central|Copperbelt|Eastern|Luapula|Lusaka|North-Western|Northern|Southern|Western"
  "Bulawayo|Harare|ManicalandMashonaland Central|Mashonaland East|Mashonaland West|Masvingo|Matabeleland North|Matabeleland South|Midlands"
]
