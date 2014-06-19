'use strict'

### Directives ###

# register the module with Angular
angular.module('app.directives', [
  # require the 'app.service' module
  'app.services'
])

.directive('appVersion', [
  'version'

(version) ->

  (scope, elm, attrs) ->
    elm.text(version)
])

.directive('wrapWith', [

  () ->
    transclude: 'element'

    link: (scope, element, attrs, ctrl, transclude) ->
      template = $templateCache.get(attrs.wrapWith)
      templateElement = angular.element(template)
      transclude(scope, (clone) ->
        element.after(templateElement.append(clone))
      )
])

.directive("debug", [
  '$compile'

  ($compile) ->
    terminal: true

    priority: 1000000

    link: (scope, element) ->
      console.log element.val()
      clone = element.clone()
      element.attr("style", "color:red")
      clone.removeAttr("debug")
      clonedElement = $compile(clone)(scope)
      element.after(clonedElement)
])

#.directive('integer', [
#
#  () ->
#    require: 'ngModel'
#
#    link: (scope, elm, attrs, ngModel) ->
#
#      ngModel.$parsers.unshift((viewValue) ->
#        if viewValue != undefined and viewValue.length > 0
#          valid = /^\-?\d+$/.test(viewValue)
#        else
#          valid = true
#        ngModel.$setValidity('number', valid)
#        return viewValue
#      )
#])
#
#.directive('float', [
#
#  () ->
#    require: 'ngModel'
#
#    link: (scope, elm, attrs, ngModel) ->
#
#      ngModel.$parsers.unshift((viewValue) ->
#        if viewValue != undefined and viewValue.length > 0
#          valid = /^\-?\d+((\.|\,)\d+)?$/.test(viewValue)
#        else
#          valid = true
#        ngModel.$setValidity('number', valid)
#        return viewValue
#      )
#])
#
#.directive('max', [
#
#  () ->
#    require: 'ngModel'
#
#    link: (scope, elm, attrs, ngModel) ->
#
#      ngModel.$parsers.unshift((viewValue) ->
#        if viewValue != undefined and viewValue.length > 0 and /^\-?\d+$/.test(viewValue)
#          valid = parseInt(viewValue) <= attrs.max
#        else
#          valid = true
#        ngModel.$setValidity('max', valid)
#        return viewValue
#      )
#])
#
#.directive('min', [
#
#  () ->
#    require: 'ngModel'
#
#    link: (scope, elm, attrs, ngModel) ->
#
#      ngModel.$parsers.unshift((viewValue) ->
#        if viewValue != undefined and viewValue.length > 0 and
#          valid = /^\-?\d+$/.test(viewValue) and parseInt(viewValue) >= attrs.min
#        else
#          valid = true
#        ngModel.$setValidity('min', valid)
#        return viewValue
#      )
#])
#
#.directive('pattern', [
#
#  () ->
#    require: 'ngModel'
#
#    link: (scope, elm, attrs, ngModel) ->
#
#      ngModel.$parsers.unshift((viewValue) ->
#        if viewValue != undefined and viewValue.length > 0
#          r = attrs.pattern.substr(1, attrs.pattern.length - 2)
#          valid = new RegExp(r).test(viewValue)
#        else
#          valid = true
#        ngModel.$setValidity('pattern', valid)
#        return viewValue
#      )
#])

.directive('filter', [
  '$filter'

  ($filter) ->
    require: 'ngModel'
    priority: 10000

    link: (scope, elm, attrs, ngModel) ->

      ngModel.$formatters.unshift((value) ->
        v = $filter(attrs.filter)(value, attrs.filterFormat)
        if attrs.filterApply? and scope.f.inputText != v
          scope.f.inputText = v
        return v
      )
])
