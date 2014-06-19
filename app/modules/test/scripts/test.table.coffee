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
