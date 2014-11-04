'use strict';

angular.module("querybuilder.services", [])

.directive("queryBuilder", [
  "$compile"
  "Rest"
  "$http"
  "$templateCache"

  ($compile, Rest, $http, $templateCache) ->
    restrict: 'E'
    scope:
      group: '='
      model: '='
    template: '<div></div>'
#    templateUrl: "/partials/querybuilder.html"

    compile: (element, attrs) ->
      content = element.contents().remove()

      (scope, element, attrs) ->

        scope.fields = []
        scope.operators = ["AND", "OR"]
        scope.conditions = ["=", "<>", "<", "<=", ">", ">="]

        if scope.model?
          m = new Rest(scope.model)
          m.getSchema((r) ->
            if r
              scope.fields = _.keys(r)
          )

        $http.get('/partials/querybuilder.html', {cache: $templateCache})
        .success((data) ->
          element.html(data)
          $compile(element.contents())(scope)
        )

        scope.addCondition = () ->
          @group.rules.push
            condition: '='
            field: (if @fields.length then @fields[0] else '')
            data: ''

        scope.removeCondition = (index) ->
          @group.rules.splice index, 1

        scope.addGroup = ->
          @group.rules.push(
            group:
              operator: 'AND'
              rules: []
          )

        scope.removeGroup = () ->
          if @$parent.group?
            @$parent.group.rules.splice(@$parent.$index, 1)
          else
            @group = null
#          directive = $compile(content)
#          element.append(directive(scope, ($compile) -> $compile))
])
