'use strict'

angular.module('blog', ['app'])

.controller('BlogCtrl', [
  '$scope'
  '$rootScope'
  'Globals'
  'Rest'
  'dynForm'

  ($scope, $rootScope, globals, Rest, dynForm) ->

    $scope.title = "Half Full Glass"
    $scope.description = "Glassfrog's official blog"

    $scope.posts = new Rest('blog')
    $scope.posts.find({l: 10, p: 'comments', sort: '-created_at'}, ->
      blogForm =
        name: "blogForm"
        layout: {type: 'grid', style: "form-inline"}

        fields: [
          fieldname: 'title'
          label: 'Blog'
          type: 'include'
          template: '/partials/blog-post-template.html'
          controller: 'BlogCtrl'
        ]

      dynForm.build($scope, blogForm, $scope.posts, '#blogpost')
    )

    $scope.like = () ->
      console.log "ok"
])

.config([
  '$stateProvider'

  ($stateProvider) ->

    $stateProvider
      .state('blog',
        abstract: true
        url:'/blog'
        templateUrl: '/partials/blog.html'
      )

      .state('blog.main',
        url:''
        icon: 'cic-pen3'
        data:
          root: 'blog'
          ncyBreadcrumbLabel: 'Blog'
        views:
          main:
            templateUrl: '/partials/blog.main.html'
            controller: 'BlogCtrl'
      )
])
