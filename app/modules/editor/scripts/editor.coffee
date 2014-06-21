angular.module('editor', ['editor.preview'])

.controller('EditorCtrl', [
  '$scope'
  '$rootScope'
  'Globals'
  '$window'
  '$timeout'
  'Editor'

  ($scope, $rootScope, globals, $window, $timeout, Editor) ->

    $scope.showCode = () ->
      alert(Editor.code())

    $timeout(->
      console.log "$window.Blockly", $window.Blockly
      $window.Blockly.JavaScript.addReservedWords('code,timeouts,checkTimeout')
    , 3000)
])

.factory('Editor', [
  '$window'

  ($window) ->

    code: () ->
      if $window.Blockly
        $window.Blockly.JavaScript.INFINITE_LOOP_TRAP = null
        code = $window.Blockly.JavaScript.workspaceToCode()
      else
        code = ''
      return code

    save: () ->
      if $window.Blockly
        dom = $window.Blockly.Xml.workspaceToDom($window.Blockly.getMainWorkspace())
        xml = $window.Blockly.Xml.domToText(dom)
      else
        xml = ''
      return xml
      
    load: (xml) ->
      if $window.Blockly
        dom = $window.Blockly.Xml.textToDom(xml)
        $window.Blockly.Xml.domToWorkspace($window.Blockly.getMainWorkspace(), dom)

    run: () ->
      if $window.Blockly
        $window.LoopTrap = 1000;
        $window.Blockly.JavaScript.INFINITE_LOOP_TRAP = 'if (--window.LoopTrap == 0) throw "Infinite loop.";\n'
        code = $window.Blockly.JavaScript.workspaceToCode()
        $window.Blockly.JavaScript.INFINITE_LOOP_TRAP = null
        try
          eval(code)
        catch e
          alert(e)

])

.config([
  '$stateProvider'

  ($stateProvider) ->
    $stateProvider

    .state('editor',
      url: '/editor'
      templateUrl: '/partials/editor.html'
    )
])
