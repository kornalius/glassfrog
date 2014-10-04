angular.module('test.form', ['dynamicForm', 'Datetimepicker'])

.controller('TestFormCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'dynForm'
  'Rest'
  '$window'

($scope, $rootScope, $injector, dynForm, Rest, $window) ->

  $scope.test = new Rest('test')

  $scope.colorFunction = -> (d, i) -> ['#FF0000', '#0000FF', '#FFFF00', '#00FFFF'][i]
  $scope.xAxisTickFormatFunction = -> (d) -> d3.time.format('%x')(new Date(d))
  $scope.yAxisTickFormatFunction = -> (d) -> d3.round(d, 2)
  $scope.xFunction = () -> (d) -> d.key
  $scope.yFunction = () -> (d) -> d.y
  $scope.descriptionFunction = () -> (d) -> d.key

  $scope.test.findById('541c8714e2e2c8c3eb412cac', ->
#  $scope.test.new( ->
    testForm =
      label: "Super form"
      name: "myForm"
      layout: {type:'form', style:'horizontal'}

      fields: [
        type: "tabs"
        tabs: [
          label: 'Main'
        ,
          label: 'Country/State'
        ,
          label: 'Check/Radio'
        ,
          label: 'Select'
        ,
          label: 'List'
        ,
          label: 'Dashboard'
        ,
          label: 'd3'
        ]
#      ,
#        label:'Dash'
#        type: 'dashboard'
#        description: 'Some dashboard'
#        options:
#          explicitSave: true
#          hideWidgetSettings: true
#          hideWidgetClose: true
#          widgetButtons: false
#          widgetDefinitions: [
#            name: 'random'
#            title: 'Random value'
#            directive: 'wt-field-watch'
#            style:
#              width: '100%'
#            attrs:
#              value: 'form.model.rows[0]._id'
#          ]
#          defaultWidgets: [
#            name: 'random'
#          ]
#          storage: $window.localStorage
#          storageId: 'dashboard'
#        tab: 5
      ,
        label: "Country"
        type: "country"
        description: "Where are you from?"
        fieldname: 'country'
        config:
          openOnFocus: true
        placeholder: "Select a Country..."
        required: true
        tab: 1
      ,
        label: "State"
        type: "state"
        description: "Which city are you from?"
        fieldname: 'state'
        config:
          openOnFocus: true
        placeholder: "Select a State..."
        required: true
        tab: 1
      ,
        label: "ID"
        type: "input"
        description: "id of the record"
        fieldname: '_id'
#        number: true
#        min: 0
#        max: 10
#        style: {name:'color', value:'darkorange'}
        color: 'darkorange'
        italic: true
  #          hidden: false
        disabled: true
        required: true
      ,
        label: "Dates Section"
        type: "group"
      ,
        label: "Created"
        type: "input"
        placeholder: "Creation date"
        description: "date the record was created"
        fieldname: 'created_at'
        datetime: true
        required: true
      ,
        label: "Updated"
        type: "input"
        description: "date the record was modified"
        fieldname: 'updated_at'
        datetime: true
        required: true
        placeholder: "Updated date"
      ,
        label: "Misc..."
        type: "group"
      ,
        label: "Radio Tests"
        type: "radio"
        description: "select an option from the list"
        options: [
          label: "Option A"
          value: 1
        ,
          label: "Option B"
          value: 2
        ,
          label: "Option C"
          value: 3
        ,
          label: "Option D"
          value: 4
        ,
          label: "Option E"
          value: 5
        ]
        fieldname: 'id2'
        tab: 2
      ,
        label: "Radio Tests 2"
        type: "radiobutton"
        description: "select an option from the list"
        options: [
          label: "Option F"
          value: 1
        ,
          label: "Option G"
          value: 2
        ,
          label: "Option H"
          value: 3
        ]
        fieldname: 'id21'
        tab: 2
      ,
        label: "Is it true?"
        caption: "I think it is true but I can be mistaken"
        type: "check"
        description: "select this box if it is true"
        fieldname: 'id3'
        options:
#          on_label: 'YES'
#          off_label: 'NO'
          show_labels: false
#          labels_placement: "right"
#          width: 40
#          height: 20
#          button_width: 20
        tab: 2
      ,
        label: "TextArea"
        type: "textarea"
        description: "enter some text with returns"
        fieldname: 'id4'
      ,
        label: "Money"
        type: "input"
        description: "how much do you think this product is worth"
        fieldname: 'id5'
        money: true
  #        placeholder: "2.34"
      ,
        label: "Number"
        type: "input"
        description: "input some number"
        fieldname: 'id54'
        number: true
#        min: 0
        max: 50
      ,
        label: "Select"
        type: "select"
        description: "make your selection my friend"
        config:
          openOnFocus: true
        options: [
          "Alain Deschênes"
          "Mélissa Dubé"
          "Ariane Deschênes"
          "Maggie Deschênes"
          "Mathilde Lauzon"
          "Pascal Lauzon"
          "Clermont Deschênes"
          "Jocelyne Jean"
          "Gaston Dubé"
          "Suzanne St-Martin"
        ]
        placeholder: "Select a selection..."
        fieldname: 'id6'
        tab: 3
      ,
        label: "Select Multiple/Ajax"
        type: "select"
        description: "make your selection my friend"
        config:
          hideSelected: true
          maxItems: 5
          url: '/api/test?l=100'

        placeholder: "Select multiple..."
        fieldname: 'id7'
        tab: 3
      ,
        label: "Icon Picker"
        type: "input"
        description: "powerful icons picker popup"
        placeholder: "Select an icon..."
        fieldname: 'icon'
        iconspicker: true
        tab: 3
      ,
        label: "Two lists"
        type: "twolist"
        options: [
          "Alain Deschênes"
          "Mélissa Dubé"
          "Ariane Deschênes"
          "Maggie Deschênes"
          "Mathilde Lauzon"
          "Pascal Lauzon"
          "Clermont Deschênes"
          "Jocelyne Jean"
          "Gaston Dubé"
          "Suzanne St-Martin"
        ]
        config:
          selectableHeader: "Available names"
          selectionHeader: "Selected names"
          keepOrder: true
        fieldname: 'id10'
        tab: 4
      ,
        label: "Check List"
        type: "checklistbox"
        options: [
          "Alain Deschênes"
          "Mélissa Dubé"
          "Ariane Deschênes"
          "Maggie Deschênes"
          "Mathilde Lauzon"
          "Pascal Lauzon"
          "Clermont Deschênes"
          "Jocelyne Jean"
          "Gaston Dubé"
          "Suzanne St-Martin"
        ]
        fieldname: 'id11'
        tab: 4
      ,
        label: "Mask"
        type: "input"
        description: "telephone mask testing"
        fieldname: 'id8'
        mask: '(999) 999-9999'
#        mask: '0xhhhhhh'
      ,
        label: "Mask"
        type: "caption"
        fieldname: 'id8'
        unmask: '(999) 999-9999'
      ,
        label: 'Subs'
        type: 'subform'
        fieldname: 'sub'
        subform:
          label: "Sub-documents"
          name: "myFormSubDocuments"
          layout: {type:'subform', style:'vertical'}
          fields: [
            label: "ID"
            type: "input"
            description: "id of the record"
            fieldname: '_id'
            required: true
#            number: true
#            min: 0
#            max: 100
            style: {name:'color', value:'darkgreen'}
#          ,
#            label: "Created"
#            type: "input"
#            placeholder: "Creation date"
#            description: "date the record was created"
#            fieldname: 'created_at'
#            datetime: true
#          ,
#            label: "Updated"
#            type: "input"
#            placeholder: "Updated date"
#            description: "date the record was modified"
#            fieldname: 'updated_at'
#            datetime: true
          ,
            label: "Test String"
            type: "input"
            placeholder: "Value"
            description: "Test string value"
            fieldname: 'testString'
          ,
            label: "Test Boolean"
            type: "check"
            description: "Test boolean value"
            fieldname: 'testBoolean'
          ,
            label: 'Sub-Dict'
            type: 'subform'
            fieldname: 'testDict'
            subform:
              label: "SubDict-documents"
              name: "myFormSubDictDocuments"
              layout: {type:'subform', style:'vertical'}
              fields: [
                label: "Test String"
                type: "input"
                placeholder: "Value"
                description: "Test string value"
                fieldname: 'testString'
              ,
                label: "Test Boolean"
                type: "check"
                description: "Test boolean value"
                fieldname: 'testBoolean'
              ]
          ]
      ,
        label: 'Dict'
        type: 'subform'
        fieldname: 'dict'
        subform:
          label: "Dict-documents"
          name: "myFormDictDocuments"
          layout: {type:'subform', style:'vertical'}
          fields: [
            label: "Test String"
            type: "input"
            placeholder: "Value"
            description: "Test string value"
            fieldname: 'testString'
          ,
            label: "Test Boolean"
            type: "check"
            description: "Test boolean value"
            fieldname: 'testBoolean'
          ]

#      ,
#        label:'Chart'
#        type: 'bar-chart'
#        description: 'Some chart test'
#        tab: 6
#        data: [
#          key: "Series 1"
#          values: [
#            [1025409600000, 0]
#            [1028088000000, -6.3382185140371]
#            [1030766400000, -5.9507873460847]
#          ]
#        ,
#          key: "Series 2"
#          values: [
#            [1025409600000, 0]
#            [1028088000000, 3.238712]
#            [1030766400000, 4.34280392]
#          ]
#        ]
#        options:
#          height: 300
#          showxaxis: true
#          showyaxis: true
#          showLegend: true
#          xAxisTickFormat: "xAxisTickFormatFunction()"
#          showControls: true
#          stacked: true
#          tooltips: true
#          xAxisLabel: 'Date'
#          yAxisLabel: 'Value'
#      ,
#
#        label:'Line Chart'
#        type: 'line-chart'
#        description: 'Some line chart test'
#        tab: 6
#        column: 6
#        data: [
#          key: "Series 1"
#          values: [ [1025409600000, 0], [1028088000000, -6.3382185140371], [1030766400000, -5.9507873460847], [1033358400000, -11.569146943813], [1036040400000, -5.4767332317425], [1038632400000, 0.50794682203014], [1041310800000, -5.5310285460542], [1043989200000, -5.7838296963382] ]
#        ,
#          key: "Series 2"
#          values: [ [1025409600000, 0], [1028088000000, -1.2813671283], [1030766400000, -8.283722], [1033358400000, -14.2371212], [1036040400000, -2.28372112], [1038632400000, 7.29371293721], [1041310800000, -9.293782913], [1043989200000, -15.2867332] ]
#        ]
#        options:
##          width: 400
#          height: 300
#          showxaxis: false
#          showyaxis: true
#          showLegend: true
#          xAxisTickFormat: "xAxisTickFormatFunction()"
#          yAxisTickFormat: "yAxisTickFormatFunction()"
#          showControls: true
#          tooltips: true
#          useInteractiveGuideLine: true
#          isArea: true
#          interpolate: "cardinal"
#          yAxisLabel: 'Value'
#      ,
#
#        label:'Pie Chart'
#        type: 'pie-chart'
#        description: 'Some pie chart test'
#        tab: 6
#        column: 6
#        data: [
#          key: "One"
#          y: 5
#        ,
#          key: "Two"
#          y: 2
#        ,
#          key: "Three"
#          y: 9
#        ,
#          key: "Four"
#          y: 7
#        ,
#          key: "Five"
#          y: 4
#        ,
#          key: "Six"
#          y: 3
#        ,
#          key: "Seven"
#          y: 9
#        ]
#        options:
#          x: "xFunction()"
#          y: "yFunction()"
##          width: 300
#          height: 300
#          showLabels: true
#          showValues: true
##          labelType: "percent"
#          showControls: true
#          tooltips: true
#          pieLabelsOutside: false

      ]

    $scope.test.rows[0].id2 = 2
    $scope.test.rows[0].id21 = 1
    $scope.test.rows[0].id3 = true
    $scope.test.rows[0].id4 = ''
    $scope.test.rows[0].id5 = ''
    $scope.test.rows[0].id54 = ''
    $scope.test.rows[0].id6 = ["Clermont Deschênes"]
    $scope.test.rows[0].id7 = ''
    $scope.test.rows[0].id8 = ''
    $scope.test.rows[0].id10 = ["Ariane Deschênes", "Clermont Deschênes"]
    $scope.test.rows[0].id11 = "Ariane Deschênes,Clermont Deschênes"
    $scope.test.rows[0].country = "Canada"
    $scope.test.rows[0].state = "Quebec"
    $scope.test.rows[0].icon = "cic-stop"

    dynForm.build($scope, testForm, $scope.test, '#form')
  )

])
