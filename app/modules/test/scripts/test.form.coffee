angular.module('test.form', ['dynamicForm', 'Datetimepicker'])

.controller('TestFormCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'dynForm'
  'Rest'

($scope, $rootScope, $injector, dynForm, Rest) ->

  $scope.test = new Rest('test')

  $scope.test.fetch('53a5c1429186770dd391c377', ->
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
        ]
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
          {value: 1, label: "Alain Deschênes"}
          {value: 2, label: "Mélissa Dubé"}
          {value: 3, label: "Ariane Deschênes"}
          {value: 4, label: "Maggie Deschênes"}
          {value: 5, label: "Mathilde Lauzon"}
          {value: 6, label: "Pascal Lauzon"}
          {value: 7, label: "Clermont Deschênes"}
          {value: 8, label: "Jocelyne Jean"}
          {value: 9, label: "Gaston Dubé"}
          {value: 10, label: "Suzanne St-Martin"}
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
          url: '/api/test?perPage=10'

        placeholder: "Select multiple..."
        fieldname: 'id7'
        tab: 3
      ,
        label: "Two lists"
        type: "twolist"
        options: [
          {value: 1, label: "Alain Deschênes"}
          {value: 2, label: "Mélissa Dubé"}
          {value: 3, label: "Ariane Deschênes"}
          {value: 4, label: "Maggie Deschênes"}
          {value: 5, label: "Mathilde Lauzon"}
          {value: 6, label: "Pascal Lauzon"}
          {value: 7, label: "Clermont Deschênes"}
          {value: 8, label: "Jocelyne Jean"}
          {value: 9, label: "Gaston Dubé"}
          {value: 10, label: "Suzanne St-Martin"}
        ]
        selected: ["Ariane Deschênes", "Clermont Deschênes"]
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
          {value: 1, label: "Alain Deschênes"}
          {value: 2, label: "Mélissa Dubé"}
          {value: 3, label: "Ariane Deschênes"}
          {value: 4, label: "Maggie Deschênes"}
          {value: 5, label: "Mathilde Lauzon"}
          {value: 6, label: "Pascal Lauzon"}
          {value: 7, label: "Clermont Deschênes"}
          {value: 8, label: "Jocelyne Jean"}
          {value: 9, label: "Gaston Dubé"}
          {value: 10, label: "Suzanne St-Martin"}
        ]
        selected: ["Ariane Deschênes", "Clermont Deschênes"]
        config:
          selectableHeader: "Available names"
          selectionHeader: "Selected names"
          keepOrder: true
        fieldname: 'id10'
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
          ,
            label: "Created"
            type: "input"
            placeholder: "Creation date"
            description: "date the record was created"
            fieldname: 'created_at'
            datetime: true
          ,
            label: "Updated"
            type: "input"
            placeholder: "Updated date"
            description: "date the record was modified"
            fieldname: 'updated_at'
            datetime: true
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
      ]
    dynForm.build($scope, testForm, $scope.test, '#form')
  )

])
