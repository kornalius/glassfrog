angular.module('todo', ['app'])

.controller('TodoCtrl', [
  '$scope'
  'Globals'

($scope, globals) ->
  $scope.todos = [
    text: "learn angular"
    done: true
  ,
    text: "build an angular app"
    done: false
  ]

  $scope.addTodo = ->
    $scope.todos.push
      text: $scope.todoText
      done: false

    $scope.todoText = ""

  $scope.remaining = ->
    count = 0
    angular.forEach $scope.todos, (todo) ->
      count += (if todo.done then 0 else 1)

    count

  $scope.archive = ->
    oldTodos = $scope.todos
    $scope.todos = []
    angular.forEach oldTodos, (todo) ->
      $scope.todos.push todo  unless todo.done

])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('todo',
      url:'/todo'
      templateUrl: '/partials/todo.html'
      controller: 'TodoCtrl'
      sidebarHidden: true
      data:
        ncyBreadcrumbLabel: 'Todo'
#          ncyBreadcrumbSkip: true
    )
])
