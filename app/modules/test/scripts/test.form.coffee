angular.module('test.form', [])

.controller('TestFormCtrl', [
  '$scope'
  '$rootScope'
  '$injector'
  'Rest'
  '$timeout'

($scope, $rootScope, $injector, Rest, $timeout) ->

  $scope.model = {}
  $scope.schema = {}
  $scope.form = []

  $scope.test = new Rest('test')
  $scope.test.findById('541c8714e2e2c8c3eb412cac', ->
    $scope.model = $scope.test.rows[0]
    $scope.model.name = "My name is Mud!"
    $scope.model.select = "Jocelyne Jean"
    $scope.model.multi = ["Alain Deschênes", "Mélissa Dubé", "Clermont Deschênes"]
    $scope.model.tags = ["Alain Deschênes", "Mélissa Dubé", "Joe"]
    $scope.model.url = "http://www.arianesoft.ca"
    $scope.model.email = "info@arianesoft.ca"
    $scope.model.phone = "514-992-5478"
    $scope.model.rating = 2
    $scope.model.checklist = ["Alain Deschênes", "Ariane Deschênes"]
    $scope.model.twolist = ["Mélissa Dubé", "Pascal Lauzon", "Marie-Sol Lefrancois"]

    $scope.test.getSchema(true, (schema, err) ->
      $scope.schema = schema

      $scope.form = [
        type: 'form-vertical'
        notitle: true
        editMode: 'always'
        canEdit: true
        items: [
          type: "callout"
          title: "Name"
          description: "Your name please."
          style: "info"
          inline: true
          items: [
            key: "name"
            notitle: true
          ]
        ,
          type: "tabs"
          tabs: [
            title: "Tab 1"
            items: [
              key: '_id'
              description: 'This is the ID of the record'
            ,
              key: 'value'
              placeholder: 'Enter a value for this record'
              minLength: 2
              required: true
            ,
              key: 'created_at'
              type: 'datetime'
              placeholder: 'Pick a date...'
            ,
              key: 'updated_at'
              type: 'datetime'
              placeholder: 'Pick a date...'
            ,
              key: 'country'
              type: 'countries'
            ,
              key: 'state'
              type: 'states'
            ,
              key: 'checklist'
              type: 'checklist'
              titleMap: ["Alain Deschênes", "Mélissa Dubé", "Ariane Deschênes"]
            ,
              key: 'twolist'
              type: 'twolist'
              titleMap: ["Alain Deschênes", "Mélissa Dubé", "Ariane Deschênes", "Mathilde Lauzon", "Pascal Lauzon", "Élodie Lauzon", "Marie-Sol Lefrancois", "Clermont Deschênes", "Jocelyne Jean"]
            ]
          ,
            title: "Tab 2"
            items: [
              type: "help"
              helpvalue: "<p></p><h4>Array Example</h4><p><em>Try adding a couple of forms, reorder by drag'n'drop.</em></p>"
            ,
              key: 'sub'
              type: 'array'
  #            tabType: 'top'
  #            title: "value.testString || ('Tab ' + $index)"
              add: ' '
              remove: ' '
              style:
                add: 'btn-success'
                remove: 'btn-danger'
              description: 'This is an array field'
              items: [
                key: 'sub[].testString'
              ,
                key: 'sub[].testBoolean'
              ,
                key: 'sub[].testDict'
                title: 'Dict'
              ]
            ]
          ]
        ,
          title: 'FieldSet'
          type: "fieldset"
          items: [
            "value"
          ,
            key: "dict.testString"
          ]
        ,
          key: 'select'
          title: 'Selectize'
          type: 'select'
          titleMap: ["Alain Deschênes", "Mélissa Dubé", "Ariane Deschênes", "Mathilde Lauzon", "Pascal Lauzon", "Élodie Lauzon", "Marie-Sol Lefrancois", "Clermont Deschênes", "Jocelyne Jean"]
        ,
          key: 'multi'
          type: 'multi'
          titleMap: ["Alain Deschênes", "Mélissa Dubé", "Ariane Deschênes", "Mathilde Lauzon", "Pascal Lauzon", "Élodie Lauzon", "Marie-Sol Lefrancois", "Clermont Deschênes", "Jocelyne Jean"]
        ,
          key: 'tags'
          type: 'tags'
          titleMap: ["Alain Deschênes", "Mélissa Dubé", "Ariane Deschênes", "Mathilde Lauzon", "Pascal Lauzon", "Élodie Lauzon", "Marie-Sol Lefrancois", "Clermont Deschênes", "Jocelyne Jean"]
        ,
          key: 'url'
          type: 'url'
        ,
          key: 'email'
          type: 'email'
        ,
          key: 'phone'
          type: 'phone'
        ,
          key: 'rating'
          type: 'rating'
          max: 5
  #        stateon: 'glyphicon-ok-sign'
  #        stateoff: 'glyphicon-ok-circle'
        ,
          type: "template"
          value: 'This is a custom template field'
          template: "/partials/decorators/test-template.html"
        ]
      ]
    )

#  $scope.colorFunction = -> (d, i) -> ['#FF0000', '#0000FF', '#FFFF00', '#00FFFF'][i]
#  $scope.xAxisTickFormatFunction = -> (d) -> d3.time.format('%x')(new Date(d))
#  $scope.yAxisTickFormatFunction = -> (d) -> d3.round(d, 2)
#  $scope.xFunction = () -> (d) -> d.key
#  $scope.yFunction = () -> (d) -> d.y
#  $scope.descriptionFunction = () -> (d) -> d.key

#    $scope.test.id2 = 2
#    $scope.test.id21 = 1
#    $scope.test.id3 = true
#    $scope.test.id4 = ''
#    $scope.test.id5 = ''
#    $scope.test.id54 = ''
#    $scope.test.id6 = ["Clermont Deschênes"]
#    $scope.test.id7 = ''
#    $scope.test.id8 = ''
#    $scope.test.id10 = ["Ariane Deschênes", "Clermont Deschênes"]
#    $scope.test.id11 = "Ariane Deschênes,Clermont Deschênes"
#    $scope.test.country = "Canada"
#    $scope.test.state = "Quebec"
#    $scope.test.icon = "cic-stop"
  )

])
