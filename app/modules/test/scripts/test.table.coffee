angular.module('test.table', ['dynamicForm'])

.controller('TestTableCtrl', [
  '$scope'
  '$rootScope'
  'Rest'

($scope, $rootScope, Rest) ->

  $scope.model = {}
  $scope.schema = {}
  $scope.form = []

  $scope.test = new Rest('test')
  $scope.test.find({l: 10}, ->
    $scope.model = $scope.test

    $scope.test.getSchema(true, (schema, err) ->
      $scope.schema = schema

      $scope.form = [
        key: 'rows'
        type: 'array'
        format: 'table'
        title: "Table view"
        items: [
          "rows[]._id"
        ,
          "rows[].created_at"
        ,
          "rows[].updated_at"
        ,
          "rows[].value"
        ]
      ]
    )
  )

])
