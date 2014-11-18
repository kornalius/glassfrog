angular.module("angular-centered", [])

.directive("centered", [

  () ->
	  restrict : "ECA",
		transclude : true,
		template : "<div class=\"angular-center-container\">\
		    				  <div class=\"angular-centered\" ng-transclude>\
				    		  </div>\
					      </div>"
])
