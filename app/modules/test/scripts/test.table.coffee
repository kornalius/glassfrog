angular.module('test.table', ['dynamicForm'])

.controller('TestTableCtrl', [
  '$scope'
  '$rootScope'
  'dynForm'
  'Rest'

($scope, $rootScope, dynForm, Rest) ->

  $scope.tests = []

  $scope.tests = new Rest('test')

  $scope.tests.fetch({perPage: 10}, ->
    testTable =
      label: 'Table test'
      name: "myTable"
      editMode: 'inline'
      canMove: false
      layout: {type:'table'}

      moreModal: {}

      editModal:
        label: "Edit"
        name: "myEditModal"
        layout: {type:'modal', style:'horizontal'}
        buttons: [{ icon: 'disk3', class: 'success', label: 'Save', url: "ok" }, { icon: null, class: 'danger', label: 'Cancel', url: "cancel" }]

        fields: [
          type: "tabs"
          tabs: [
            label: 'Main'
          ,
            label: 'Dates'
          ]
        ,
          label: "ID"
          type: "input"
          description: "id of the record"
          fieldname: '_id'
          style: {name:'color', value:'darkorange'}
          required: true
        ,
          label: "Created"
          type: "input"
          placeholder: "Creation date"
          description: "date the record was created"
          fieldname: 'created_at'
          datetime: true
          required: true
          tab: 1
        ,
          label: "Updated"
          type: "input"
          description: "date the record was modified"
          fieldname: 'updated_at'
          datetime: true
          required: true
          placeholder: "Updated date"
          tab: 1
      ]

      fields: [
        label: "#"
        type: "input"
        description: "id of the record"
        fieldname: '_id'
#        number: true
#        min: 0
#        max: 10
        width: '10%'
        style: {name:'color', value:'darkorange'}
#          hidden: false
#          disabled: true
        required: true
        sum: '"Count:" + rows.length'
      ,
        label: "Created"
        type: "input"
        placeholder: "Creation date"
        description: "date the record was created"
        fieldname: 'created_at'
        width: '10%'
#        datetime: true
        required: true
      ,
        label: "Updated"
        type: "input"
        description: "date the record was modified"
        fieldname: 'updated_at'
        width: '10%'
#        datetime: true
        required: true
        placeholder: "Updated date"
      ]

    dynForm.build($scope, testTable, $scope.tests, '#table')
  )
])
