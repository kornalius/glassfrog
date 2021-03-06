module.exports = (grunt) ->

  _ = require('lodash')

  out_dev = "_public/"
  server_out_dev = "_server/"
  tmp_dev = "_tmp/"

  out = "/Volumes/AWS Glassfrog/www/_public/"
  server_out = "/Volumes/AWS Glassfrog/www/_server/"
  tmp = "_tmp/"

  #  Project configuration.
  grunt.initConfig(
    clean:
      dev: [
        tmp_dev
        out_dev
      ]

      server_dev: [
        tmp_dev
        server_out_dev
      ]

      prod: [
        tmp
        out
      ]

      server_prod: [
        tmp
        server_out
      ]

    coffee:
      dev:
        options:
          join: true
#          sourceMap: true
        files: [
          src: 'app/**/*.coffee'
          dest: out_dev + 'js/app.js'
        ,
          src: 'scripts/**/*.coffee'
          dest: out_dev + 'js/scripts.js'
        ]

      prod:
        options:
          join: true
        files: [
          src: 'app/**/*.coffee'
          dest: out + 'js/app.js'
        ,
          src: 'scripts/**/*.coffee'
          dest: out + 'js/scripts.js'
        ]

      server_dev:
        options:
          join: true
#          sourceMap: true
        files: [
          expand: true
          cwd: 'scripts/'
          src: '**/*.coffee'
          dest: server_out_dev
          ext: '.js'
        ,
          expand: true
          cwd: 'server/'
          src: '**/*.coffee'
          dest: server_out_dev
          ext: '.js'
        ]

      server_prod:
        options:
          join: true
#          sourceMap: true
        files: [
          expand: true
          cwd: 'scripts/'
          src: '**/*.coffee'
          dest: server_out
          ext: '.js'
        ,
          expand: true
          cwd: 'server/'
          src: '**/*.coffee'
          dest: server_out
          ext: '.js'
        ]

    less:
      dev:
        files: [
          src: "app/styles/app.less"
          dest: out_dev + "css/app.css"
        ]

      prod:
        files: [
          src: "app/styles/app.less"
          dest: out + "css/app.css"
        ]

    jade:
      dev:
        files: [
          expand: true
          flatten: true
          cwd: 'app/modules/'
          src: '**/*.jade'
          dest: out_dev + 'partials/'
          rename: (dest, src) ->
            folder    = src.substring(0, src.lastIndexOf('/'))
            filename  = src.substring(src.lastIndexOf('/'), src.length)
            filename  = filename.substring(0, filename.lastIndexOf('.'))
            return dest + folder + filename + '.html'
        ,
          src: 'app/scripts/pagination.jade'
          dest: out_dev + 'partials/pagination.html'
        ,
          src: 'app/scripts/querybuilder.jade'
          dest: out_dev + 'partials/querybuilder.html'
        ]
        options:
          pretty: true

      prod:
        files: [
          expand: true
          flatten: true
          cwd: 'app/modules/'
          src: '**/*.jade'
          dest: out + 'partials/'
          rename: (dest, src) ->
            folder    = src.substring(0, src.lastIndexOf('/'))
            filename  = src.substring(src.lastIndexOf('/'), src.length)
            filename  = filename.substring(0, filename.lastIndexOf('.'))
            return dest + folder + filename + '.html'
        ,
          src: 'app/scripts/pagination.jade'
          dest: out + 'partials/pagination.html'
        ,
          src: 'app/scripts/querybuilder.jade'
          dest: out + 'partials/querybuilder.html'
        ]

      devDynForm:
        files: [
          expand: true
          flatten: true
          cwd: 'app/dynFormTemplates/'
          src: '**/*.jade'
          dest: tmp_dev + 'partials/dynFormTemplates/'
          rename: (dest, src) ->
            folder    = src.substring(0, src.lastIndexOf('/'))
            filename  = src.substring(src.lastIndexOf('/'), src.length)
            filename  = filename.substring(0, filename.lastIndexOf('.'))
            return dest + folder + filename + '.html'
        ]
        options:
          pretty: true

      prodDynForm:
        files: [
          expand: true
          flatten: true
          cwd: 'app/dynFormTemplates/'
          src: '**/*.jade'
          dest: tmp + 'partials/dynFormTemplates/'
          rename: (dest, src) ->
            folder    = src.substring(0, src.lastIndexOf('/'))
            filename  = src.substring(src.lastIndexOf('/'), src.length)
            filename  = filename.substring(0, filename.lastIndexOf('.'))
            return dest + folder + filename + '.html'
        ]

    copy:
      dev:
        files: [
          expand: true
          cwd: 'app/assets/'
          src: '**/*'
          dest: out_dev
        ,
          expand: true
          cwd: 'bower_components/bootstrap/dist/fonts'
          src: '*'
          dest: out_dev + 'fonts'
        ,
          expand: true
          cwd: 'bower_components/fancytree/dist/skin-lion'
          src: '*.gif'
          dest: out_dev + 'css'
        ,
          src: 'node_modules/assurance/build/assurance.js'
          dest: out_dev + 'js/assurance.js'
        ,
          src: 'node_modules/async/lib/async.js'
          dest: out_dev + 'js/async.js'
        ,
          src: 'node_modules/humanize-plus/public/src/humanize.js'
          dest: out_dev + 'js/humanize.js'
        ]

      prod:
        files: [
          expand: true
          cwd: 'app/assets/'
          src: '**/*'
          dest: out
        ,
          expand: true
          cwd: 'bower_components/bootstrap/dist/fonts'
          src: '*'
          dest: out + 'fonts'
        ,
          expand: true
          cwd: 'bower_components/fancytree/dist/skin-lion'
          src: '*.gif'
          dest: out + 'css'
        ,
          src: 'node_modules/assurance/build/assurance.min.js'
          dest: out + 'js/assurance.js'
        ,
          src: 'node_modules/async/lib/async.js'
          dest: out + 'js/async.js'
        ,
          src: 'node_modules/humanize-plus/public/src/humanize.js'
          dest: out + 'js/humanize.js'
        ]

      server_dev:
        files: [
          expand: true
          cwd: 'server/views/'
          src: '*.jade'
          dest: server_out_dev + 'views/'
        ,
          expand: true
          cwd: 'server/config/'
          src: '*'
          dest: server_out_dev + 'config/'
        ,
          expand: true
          cwd: 'server/components'
          src: '*.hbs'
          dest: server_out_dev + 'components'
        ]

      server_prod:
        files: [
          expand: true
          cwd: 'server/views/'
          src: '*.jade'
          dest: server_out + 'views/'
        ,
          expand: true
          cwd: 'server/config/'
          src: '*'
          dest: server_out + 'config/'
        ,
          expand: true
          cwd: 'server/components'
          src: '*.hbs'
          dest: server_out + 'components'
        ]

    concat:
      dev:
        files: [
          src: [
            'bower_components/lodash/dist/lodash.js'
            'node_modules/lodash-deep/lodash-deep.js'
            'node_modules/underscore.string/lib/underscore.string.js'
            'node_modules/underscore-query/lib/underscore-query.js'
#            'node_modules/lodash-prototype/lodash-prototype.js'
            'node_modules/sugar/release/sugar-full.development.js'
            'bower_components/traverse/traverse.js'
            'node_modules/js-beautify/js/lib/beautify.js'
            'node_modules/circular-json/build/circular-json.js'
            'bower_components/jquery/dist/jquery.js'
            'bower_components/jquery-ui/ui/jquery-ui.js'
            'bower_components/moment/moment.js'
            'bower_components/moment/lang/en_ca.js'
            'bower_components/moment/lang/fr.js'
            'bower_components/moment/lang/fr_ca.js'
            'bower_components/bootstrap/dist/js/bootstrap.js'
            'bower_components/angular/angular.js'
            'bower_components/angular-sanitize/angular-sanitize.js'
            'bower_components/angular-cookies/angular-cookies.js'
            'bower_components/angular-resource/angular-resource.js'
            'bower_components/angular-animate/angular-animate.js'
            'bower_components/angular-ui-router/release/angular-ui-router.js'
            'bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
            'bower_components/i18next/i18next.js'
            'bower_components/ng-i18next/dist/ng-i18next.js'
            'bower_components/restangular/dist/restangular.js'
            'bower_components/select2/select2.js'
            'bower_components/ng-table/ng-table.js'
            'bower_components/angular-ui/build/angular-ui.js'
            'bower_components/eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min.js'
            'bower_components/jquery-maskedinput/dist/jquery.maskedinput.js'
            'bower_components/angular-webstorage/angular-webstorage.js'
            'bower_components/jquery-switchbutton/jquery.switchButton.js'
            'bower_components/multiselect/js/jquery.multi-select.js'
            'bower_components/angular-filters/dist/angular-filters.js'
            'bower_components/angular-lodash/angular-lodash.js'
            'bower_components/angular-underscore-string/angular-underscore-string.js'
            'bower_components/tinycolor/tinycolor.js'
            'bower_components/selectize/dist/js/standalone/selectize.js'
            'bower_components/angular-breadcrumb/dist/angular-breadcrumb.js'
            'bower_components/spectrum/spectrum.js'
            'bower_components/angular-spectrum-colorpicker/dist/angular-spectrum-colorpicker.js'
            'bower_components/bootstrap-touchspin/dist/jquery.bootstrap-touchspin.js'
            'bower_components/jquery-smooth-scroll/jquery.smooth-scroll.js'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.js'
            'bower_components/angular-ui-sortable/sortable.js'
            'bower_components/malhar-angular-dashboard/dist/angular-ui-dashboard.js'
            'bower_components/malhar-angular-widgets/dist/malhar-angular-widgets.js'
            'bower_components/d3/d3.js'
            'bower_components/nvd3/nv.d3.js'
            'bower_components/angularjs-nvd3-directives/dist/angularjs-nvd3-directives.js'
            'bower_components/pines-notify/pnotify.core.js'
            'bower_components/pines-notify/pnotify.buttons.js'
            'bower_components/pines-notify/pnotify.callbacks.js'
            'bower_components/pines-notify/pnotify.confirm.js'
            'bower_components/pines-notify/pnotify.desktop.js'
            'bower_components/pines-notify/pnotify.history.js'
            'bower_components/pines-notify/pnotify.nonblock.js'
            'bower_components/pines-notify/pnotify.reference.js'
            'bower_components/angular-pines-notify/src/pnotify.js'
            'bower_components/fontawesome-iconpicker/dist/js/fontawesome-iconpicker.js'
            'bower_components/angular-moment/angular-moment.js'
            'bower_components/marked/lib/marked.js'
            'bower_components/angular-marked/angular-marked.js'
            'bower_components/angular-loading-bar/build/loading-bar.js'
            'bower_components/angular-pageslide-directive/dist/angular-pageslide-directive.js'
            'bower_components/perfect-scrollbar/src/perfect-scrollbar.js'
            'bower_components/angular-perfect-scrollbar/src/angular-perfect-scrollbar.js'
            'bower_components/tv4/tv4.js'
            'bower_components/objectpath/lib/ObjectPath.js'
            'bower_components/angular-schema-form/dist/schema-form.js'
#            'bower_components/angular-input-modified/dist/angular-input-modified.js'
            'bower_components/ng-click-select/ng-click-select.js'
            'bower_components/ng-scope/ng-scope.js'
            'bower_components/angular-blocks/dist/angular-blocks.js'
            'node_modules/diff/diff.js'
            'node_modules/flat/index.js'
            'node_modules/acorn/acorn.js'
            'bower_components/requirejs/require.js'
            tmp_dev + '/dynFormTemplates.js'
            tmp_dev + '/decorators.js'
          ]
          dest: out_dev + 'js/vendor.js'
        ,
          src: [
            'bower_components/lodash/dist/lodash.js'
            'node_modules/underscore.string/lib/underscore.string.js'
            'node_modules/underscore-query/lib/underscore-query.js'
#            'node_modules/lodash-prototype/lodash-prototype.js'
            'node_modules/sugar/release/sugar-full.development.js'
            'bower_components/traverse/traverse.js'
            'node_modules/circular-json/build/circular-json.js'
            'bower_components/jquery/dist/jquery.js'
            'bower_components/jquery-ui/ui/jquery-ui.js'
            'bower_components/moment/moment.js'
            'bower_components/tinycolor/tinycolor.js'
            'bower_components/bootstrap/dist/js/bootstrap.js'
            'bower_components/i18next/i18next.js'
            'bower_components/selectize/dist/js/standalone/selectize.js'
            'bower_components/jquery-smooth-scroll/jquery.smooth-scroll.js'
            'bower_components/pines-notify/pnotify.core.js'
            'bower_components/pines-notify/pnotify.buttons.js'
            'bower_components/pines-notify/pnotify.callbacks.js'
            'bower_components/pines-notify/pnotify.confirm.js'
            'bower_components/pines-notify/pnotify.desktop.js'
            'bower_components/pines-notify/pnotify.history.js'
            'bower_components/pines-notify/pnotify.nonblock.js'
            'bower_components/pines-notify/pnotify.reference.js'
            'bower_components/perfect-scrollbar/src/perfect-scrollbar.js'
            'bower_components/requirejs/require.js'
          ]
          dest: out_dev + 'js/index.js'
        ,
          src: [
            'bower_components/select2/select2.css'
            'bower_components/eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min.css'
            'bower_components/yamm3/yamm/yamm.css'
            'bower_components/jquery-ui/themes/base/jquery-ui.css'
            'bower_components/ng-table/ng-table.css'
            'bower_components/angular-ui/build/angular-ui.css'
            'bower_components/jquery-switchbutton/jquery.switchButton.css'
            'bower_components/multiselect/css/multi-select.css'
            'bower_components/selectize/dist/css/selectize.bootstrap3.css'
            'bower_components/spectrum/spectrum.css'
            'bower_components/bootstrap-touchspin/dist/jquery.bootstrap-touchspin.css'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.min.css'
            'bower_components/malhar-angular-dashboard/dist/angular-ui-dashboard.css'
            'bower_components/pines-notify/pnotify.core.css'
            'bower_components/pines-notify/pnotify.buttons.css'
            'bower_components/pines-notify/pnotify.history.css'
            'bower_components/pines-notify/pnotify.picon.css'
            'bower_components/nvd3/nv.d3.css'
            'bower_components/fontawesome-iconpicker/dist/css/fontawesome-iconpicker.css'
            'bower_components/angular-loading-bar/build/loading-bar.css'
            'bower_components/perfect-scrollbar/src/perfect-scrollbar.css'
            'bower_components/bootstrap-vertical-tabs/bootstrap.vertical-tabs.css'
          ]
          dest: out_dev + 'css/vendor.css'
        ,
          src: [
            'bower_components/yamm3/yamm/yamm.css'
            'bower_components/jquery-ui/themes/base/minified/jquery-ui.css'
            'bower_components/jquery-switchbutton/jquery.switchButton.css'
            'bower_components/selectize/dist/css/selectize.bootstrap3.css'
            'bower_components/spectrum/spectrum.css'
            'bower_components/pines-notify/pnotify.core.css'
            'bower_components/pines-notify/pnotify.buttons.css'
            'bower_components/pines-notify/pnotify.history.css'
            'bower_components/pines-notify/pnotify.picon.css'
            'bower_components/perfect-scrollbar/src/perfect-scrollbar.css'
            'bower_components/bootstrap-vertical-tabs/bootstrap.vertical-tabs.css'
          ]
          dest: out_dev + 'css/index.css'
        ]

      prod:
        files: [
          src: [
            'bower_components/lodash/dist/lodash.min.js'
            'node_modules/lodash-deep/lodash-deep.min.js'
            'node_modules/underscore.string/dist/underscore.string.min.js'
            'node_modules/underscore-query/lib/underscore-query.min.js'
#            'node_modules/lodash-prototype/lodash-prototype.js'
            'node_modules/sugar/release/sugar-full.development.js'
            'bower_components/traverse/traverse.js'
            'node_modules/js-beautify/js/lib/beautify.js'
            'node_modules/circular-json/build/circular-json.js'
            'bower_components/jquery/dist/jquery.min.js'
            'bower_components/jquery-ui/ui/minified/jquery-ui.min.js'
            'bower_components/moment/min/moment-with-langs.min.js'
            'bower_components/bootstrap/dist/js/bootstrap.min.js'
            'bower_components/angular/angular.min.js'
            'bower_components/angular-sanitize/angular-sanitize.min.js'
            'bower_components/angular-cookies/angular-cookies.min.js'
            'bower_components/angular-resource/angular-resource.min.js'
            'bower_components/angular-animate/angular-animate.min.js'
            'bower_components/angular-ui-router/release/angular-ui-router.min.js'
            'bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
            'bower_components/i18next/i18next.min.js'
            'bower_components/ng-i18next/dist/ng-i18next.min.js'
            'bower_components/restangular/dist/restangular.min.js'
            'bower_components/select2/select2.min.js'
            'bower_components/ng-table/ng-table.min.js'
            'bower_components/angular-ui/build/angular-ui.min.js'
            'bower_components/eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min.js'
            'bower_components/jquery-maskedinput/dist/jquery.maskedinput.min.js'
            'bower_components/angular-webstorage/angular-webstorage.js'
            'bower_components/jquery-switchbutton/jquery.switchButton.js'
            'bower_components/multiselect/js/jquery.multi-select.js'
            'bower_components/angular-filters/dist/angular-filters.min.js'
            'bower_components/angular-lodash/angular-lodash.js'
            'bower_components/angular-underscore-string/angular-underscore-string.js'
            'bower_components/tinycolor/tinycolor.js'
            'bower_components/selectize/dist/js/standalone/selectize.min.js'
            'bower_components/angular-breadcrumb/dist/angular-breadcrumb.min.js'
            'bower_components/spectrum/spectrum.js'
            'bower_components/angular-spectrum-colorpicker/dist/angular-spectrum-colorpicker.min.js'
            'bower_components/bootstrap-touchspin/dist/jquery.bootstrap-touchspin.min.js'
            'bower_components/jquery-smooth-scroll/jquery.smooth-scroll.min.js'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.min.js'
            'bower_components/angular-ui-sortable/sortable.min.js'
            'bower_components/malhar-angular-dashboard/dist/angular-ui-dashboard.js'
            'bower_components/d3/d3.min.js'
            'bower_components/nvd3/nv.d3.min.js'
            'bower_components/angularjs-nvd3-directives/dist/angularjs-nvd3-directives.min.js'
            'bower_components/malhar-angular-widgets/dist/malhar-angular-widgets.js'
            'bower_components/pines-notify/pnotify.core.js'
            'bower_components/pines-notify/pnotify.buttons.js'
            'bower_components/pines-notify/pnotify.callbacks.js'
            'bower_components/pines-notify/pnotify.confirm.js'
            'bower_components/pines-notify/pnotify.desktop.js'
            'bower_components/pines-notify/pnotify.history.js'
            'bower_components/pines-notify/pnotify.nonblock.js'
            'bower_components/pines-notify/pnotify.reference.js'
            'bower_components/angular-pines-notify/src/pnotify.js'
            'bower_components/fontawesome-iconpicker/dist/js/fontawesome-iconpicker.min.js'
            'bower_components/angular-moment/angular-moment.min.js'
            'bower_components/marked/lib/marked.js'
            'bower_components/angular-marked/angular-marked.min.js'
            'bower_components/angular-loading-bar/build/loading-bar.min.js'
            'bower_components/angular-pageslide-directive/dist/angular-pageslide-directive.min.js'
            'bower_components/perfect-scrollbar/min/perfect-scrollbar.min.js'
            'bower_components/angular-perfect-scrollbar/src/angular-perfect-scrollbar.js'
            'bower_components/tv4/tv4.js'
            'bower_components/objectpath/lib/ObjectPath.js'
            'bower_components/angular-schema-form/dist/schema-form.min.js'
#            'bower_components/angular-input-modified/dist/angular-input-modified.min.js'
            'bower_components/ng-click-select/ng-click-select.js'
            'bower_components/ng-scope/ng-scope.js'
            'bower_components/angular-blocks/dist/angular-blocks.min.js'
            'node_modules/diff/diff.js'
            'node_modules/flat/index.js'
            'node_modules/acorn/acorn.js'
            'bower_components/requirejs/require.js'
            tmp + '/dynFormTemplates.js'
            tmp + '/decorators.js'
          ]
          dest: out + 'js/vendor.js'
        ,
          src: [
            'bower_components/lodash/dist/lodash.min.js'
            'node_modules/underscore.string/dist/underscore.string.min.js'
            'node_modules/underscore-query/lib/underscore-query.js'
#            'node_modules/lodash-prototype/lodash-prototype.js'
            'node_modules/sugar/release/sugar-full.development.js'
            'bower_components/traverse/traverse.js'
            'node_modules/circular-json/build/circular-json.js'
            'bower_components/jquery/dist/jquery.min.js'
            'bower_components/jquery-ui/ui/jquery-ui.min.js'
            'bower_components/moment/moment-with-langs.min.js'
            'bower_components/tinycolor/tinycolor.js'
            'bower_components/bootstrap/dist/js/bootstrap.min.js'
            'bower_components/i18next/i18next.min.js'
            'bower_components/selectize/dist/js/standalone/selectize.min.js'
            'bower_components/jquery-smooth-scroll/jquery.smooth-scroll.min.js'
            'bower_components/pines-notify/pnotify.core.js'
            'bower_components/pines-notify/pnotify.buttons.js'
            'bower_components/pines-notify/pnotify.callbacks.js'
            'bower_components/pines-notify/pnotify.confirm.js'
            'bower_components/pines-notify/pnotify.desktop.js'
            'bower_components/pines-notify/pnotify.history.js'
            'bower_components/pines-notify/pnotify.nonblock.js'
            'bower_components/pines-notify/pnotify.reference.js'
            'bower_components/perfect-scrollbar/min/perfect-scrollbar.min.js'
            'bower_components/requirejs/require.js'
          ]
          dest: out + 'js/index.js'
        ,
          src: [
            'bower_components/eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min.css'
            'bower_components/yamm3/yamm/yamm.css'
            'bower_components/jquery-ui/themes/base/minified/jquery-ui.min.css'
            'bower_components/ng-table/ng-table.css'
            'bower_components/angular-ui/build/angular-ui.min.css'
            'bower_components/jquery-switchbutton/jquery.switchButton.css'
            'bower_components/multiselect/css/multi-select.css'
            'bower_components/selectize/dist/css/selectize.bootstrap3.css'
            'bower_components/spectrum/spectrum.css'
            'bower_components/bootstrap-touchspin/dist/jquery.bootstrap-touchspin.min.css'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.min.css'
            'bower_components/malhar-angular-dashboard/dist/angular-ui-dashboard.css'
            'bower_components/pines-notify/pnotify.core.css'
            'bower_components/pines-notify/pnotify.buttons.css'
            'bower_components/pines-notify/pnotify.history.css'
            'bower_components/pines-notify/pnotify.picon.css'
            'bower_components/nvd3/nv.d3.min.css'
            'bower_components/fontawesome-iconpicker/dist/css/fontawesome-iconpicker.min.css'
            'bower_components/angular-loading-bar/build/loading-bar.min.css'
            'bower_components/perfect-scrollbar/min/perfect-scrollbar.min.css'
            'bower_components/bootstrap-vertical-tabs/bootstrap.vertical-tabs.min.css'
          ]
          dest: out + 'css/vendor.css'
        ,
          src: [
            'bower_components/yamm3/yamm/yamm.css'
            'bower_components/jquery-ui/themes/base/minified/jquery-ui.min.css'
            'bower_components/jquery-switchbutton/jquery.switchButton.css'
            'bower_components/selectize/dist/css/selectize.bootstrap3.css'
            'bower_components/spectrum/spectrum.css'
            'bower_components/pines-notify/pnotify.core.css'
            'bower_components/pines-notify/pnotify.buttons.css'
            'bower_components/pines-notify/pnotify.history.css'
            'bower_components/pines-notify/pnotify.picon.css'
            'bower_components/perfect-scrollbar/min/perfect-scrollbar.min.css'
            'bower_components/bootstrap-vertical-tabs/bootstrap.vertical-tabs.min.css'
          ]
          dest: out + 'css/index.css'
        ]

    "file-creator":
      options:
        openFlags: 'w'
      dev: {}
      prod: {}

    html2js:
      options:
        module: 'schemaFormCustomDecorators'
        singleModule: true
        jade:
          doctype: 'html'
        base: 'app/'
        rename: (moduleName) ->
          return '/partials/' + moduleName.replace('.jade', '.html')

      dev:
        options:
          jade:
            pretty: true
        src: ['app/decorators/**/*.jade']
        dest: tmp_dev + 'decorators.js'

      prod:
        options:
          htmlmin:
            collapseBooleanAttributes: true
            collapseWhitespace: true
            removeAttributeQuotes: true
            removeComments: true
            removeEmptyAttributes: true
            removeRedundantAttributes: true
            removeScriptTypeAttributes: true
            removeStyleLinkTypeAttributes: true
        src: ['app/decorators/**/*.jade']
        dest: tmp + 'decorators.js'

    watch:
      options:
        spawn: false
        livereload: true
#        debounceDelay: 1000

      gruntfile:
        files: ['Gruntfile.coffee']
        tasks: (if grunt.cli.tasks.length then grunt.cli.tasks else ['default'])
        options:
          interrupt: true
          reload: true

      html:
        files: ['app/**/*.html', 'server/**/*.html']
        tasks: ['reload']

      app_jade:
        files: ['app/**/*.jade']
        tasks: ['jade:dev', 'reload']

      app_jadeDynForm:
        files: ['app/dynFormTemplates/*.jade']
        tasks: ['jade:dev', 'jade:devDynForm', 'file-creator:dev', 'concat:dev', 'reload']

      app_jadeDecorators:
        files: ['app/decorators/*.jade']
        tasks: ['html2js:dev', 'concat:dev', 'reload']

#      bower:
#        files: ['bower_components/**/*']
#        tasks: ['concat:dev', 'reload']

#      npm:
#        files: ['node_modules/**/*']
#        tasks: ['reload']

      app_js:
        files: ['app/**/*.js']
        tasks: ['concat:dev', 'copy:dev', 'reload']

      app_less:
        files: ['app/**/*.less']
        tasks: ['less:dev', 'reload']

      app_coffee:
        files: ['app/**/*.coffee']
        tasks: ['coffee:dev', 'concat:dev', 'copy:dev', 'reload']

      server_coffee:
        files: ['server/**/*.coffee']
        tasks: ['coffee:server_dev', 'copy:server_dev', 'express:dev', 'reload']

      server_jade:
        files: ['server/**/*.jade']
        tasks: ['copy:server_dev', 'reload']

      global_coffee:
        files: ['scripts/**/*.coffee']
        tasks: ['coffee:server_dev', 'copy:server_dev', 'coffee:dev', 'concat:dev', 'copy:dev', 'express:dev', 'reload']

#      server_js:
#        files: ['server/**/*.js']
#        tasks: ['copy:server_dev']

#      server_config:
#        files: ['server/config/**']
#        tasks: ['coffee:server_dev', 'copy:server_dev', 'express:dev', 'reload']

    express:
      options:
        cmd: process.argv[0]
        args: []
        background: true
        script: '_server/app.js'

      dev:
        options:
          port: 3000
          node_env: 'development'
          debug: true

#    env:
#      options: {}
#
#      dev:
#        NODE_ENV: 'development'
#
#      build:
#        NODE_ENV: 'production'

#    curl:
#      dev: 'http://localhost:35729/changed?files=/js/app.js'

#    open:
#      dev:
#        path: 'http://localhost:3000'
#        app: '/Applications/Firefox.app'
  )

  grunt.config.data['file-creator'].dev[tmp_dev + 'dynFormTemplates.js'] = (fs, fd, done) ->
      _ = grunt.util._
      grunt.file.glob(tmp_dev + '/partials/dynFormTemplates/*.html', (err, files) ->
        fs.writeSync(fd, "define('dynFormTemplates', function() {\n")
        fs.writeSync(fd, "  return {\n")
        t = []
        _.each(files, (file) ->
          c = fs.readFileSync(file, 'utf8')
          c = c.replace(/'/g, "\\\'").replace(/\n/g, "\\n' + " + "\n      '")
          n = file.split('.').shift().split('\/').pop()
          t.push("    '" + n + "': '" + c + "'")
        )
        fs.writeSync(fd, t.join(',\n\n') + '\n')
        fs.writeSync(fd, '  }\n')
        fs.writeSync(fd, '});\n')
        done()
      )

  grunt.config.data['file-creator'].prod[tmp + 'dynFormTemplates.js'] = (fs, fd, done) ->
      _ = grunt.util._
      grunt.file.glob(tmp + '/partials/dynFormTemplates/*.html', (err, files) ->
        fs.writeSync(fd, "define('dynFormTemplates', function() {\n")
        fs.writeSync(fd, "  return {\n")
        t = []
        _.each(files, (file) ->
          c = fs.readFileSync(file, 'utf8')
          c = c.replace(/'/g, "\\\'").replace(/\n/g, "\\n' + " + "\n      '")
          n = file.split('.').shift().split('\/').pop()
          t.push("    '" + n + "': '" + c + "'")
        )
        fs.writeSync(fd, t.join(',\n\n') + '\n')
        fs.writeSync(fd, '  }\n')
        fs.writeSync(fd, '});\n')
        done()
      )

#  d = grunt.config.data['file-creator'].dev
#  if d
#    for k of d
#      d[k.replace(/\{tmp_dev\}/g, tmp_dev)] = d[k]
#      delete d[k]
#
#  d = grunt.config.data['file-creator'].prod
#  if d
#    for k of d
#      d[k.replace(/\{tmp\}/g, tmp)] = d[k]
#      delete d[k]


  #  Load the plugin that provides the "uglify" task.
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-jade')
  grunt.loadNpmTasks('grunt-contrib-less')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-rename')
  grunt.loadNpmTasks('grunt-contrib-concat')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-express-server')
  grunt.loadNpmTasks('grunt-file-creator')
  grunt.loadNpmTasks('grunt-html2js')
#  grunt.loadNpmTasks('grunt-env')
#  grunt.loadNpmTasks('grunt-open')
#  grunt.loadNpmTasks('grunt-curl')

#  grunt.registerTask("reload", "reload Chrome on OS X", () ->
#    require("child_process").exec("osascript " +
#        "-e 'delay 0.5' " +
#        "-e 'tell application \"Google Chrome\" " +
#          "to tell the active tab of its first window' " +
#        "-e 'reload' " +
#        "-e 'end tell'")
#  )

  grunt.registerTask("reload", "reload browser", () ->
#    console.log "reload triggered"
#    setTimeout( ->
#      http = require('http')
#      console.log "livereload call"
#      http.get('http://localhost:35729/changed?files=/js/app.js', (res) ->
#        console.log "livereload called successfuly"
#      ).on('error', (e) ->
#        console.log e
#      )
#    , 500)
#    grunt.task.run('curl')
  )


  # no server configuration adjustments
  if grunt.option('noserver')

    grunt.config('coffee.dev.options.sourceMap', true)
    grunt.config('coffee.server_dev.options.sourceMap', true)
    grunt.config('watch.options.livereload', false)

    for k of grunt.config('watch')
      c = grunt.config('watch.' + k)
      if c.tasks
        grunt.config('watch.' + k + '.tasks', _.filter(c.tasks, (t) -> t != 'express:dev' and t != 'reload'))
        console.log grunt.config('watch.' + k + '.tasks')


  #  Default task(s).
  grunt.registerTask('default', ['clean:server_dev', 'coffee:server_dev', 'copy:server_dev', 'clean:dev', 'less:dev', 'coffee:dev', 'copy:dev', 'jade:dev', 'jade:devDynForm', 'html2js:dev', 'file-creator:dev', 'concat:dev', 'express:dev', 'reload', 'watch'])

  grunt.registerTask('prod', ['clean:server_prod', 'coffee:server_prod', 'copy:server_prod', 'clean:prod', 'less:prod', 'coffee:prod', 'copy:prod', 'jade:prod', 'jade:prodDynForm', 'html2js:prod', 'file-creator:prod', 'concat:prod'])

  grunt.registerTask('debug', ['clean:server_dev', 'coffee:server_dev', 'copy:server_dev', 'clean:dev', 'less:dev', 'coffee:dev', 'copy:dev', 'jade:dev', 'jade:devDynForm', 'html2js:dev', 'file-creator:dev', 'concat:dev', 'reload', 'watch'])
