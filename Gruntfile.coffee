module.exports = (grunt) ->

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
        files: [
          src: 'app/**/*.coffee'
          dest: out_dev + 'js/app.js'
          options:
            join: true
            sourceMap: true
        ,
          src: 'scripts/**/*.coffee'
          dest: out_dev + 'js/scripts.js'
          options:
            join: true
            sourceMap: true
        ]

      prod:
        files: [
          src: 'app/**/*.coffee'
          dest: out + 'js/app.js'
          options:
            join: true
            sourceMap: true
        ,
          src: 'scripts/**/*.coffee'
          dest: out + 'js/scripts.js'
          options:
            join: true
            sourceMap: true
        ]

      server_dev:
        files: [
          expand: true
          cwd: 'scripts/'
          src: '**/*.coffee'
          dest: server_out_dev
          ext: '.js'
          options:
            sourceMap: true
        ,
          expand: true
          cwd: 'server/'
          src: '**/*.coffee'
          dest: server_out_dev
          ext: '.js'
          options:
            sourceMap: true
        ]

      server_prod:
        files: [
          expand: true
          cwd: 'scripts/'
          src: '**/*.coffee'
          dest: server_out
          ext: '.js'
          options:
            sourceMap: true
        ,
          expand: true
          cwd: 'server/'
          src: '**/*.coffee'
          dest: server_out
          ext: '.js'
          options:
            sourceMap: true
        ]

    less:
      dev:
        files: [
          src: "app/styles/app.less"
          dest: out_dev + "css/app.css"
        ,
          src: "bower_components/font-awesome/less/font-awesome.less"
          dest: out_dev + "css/font-awesome.css"
        ]

      prod:
        files: [
          src: "app/styles/app.less"
          dest: out + "css/app.css"
        ,
          src: "bower_components/font-awesome/less/font-awesome.less"
          dest: out + "css/font-awesome.css"
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
          cwd: 'bower_components/font-awesome/fonts'
          src: '*'
          dest: out_dev + 'fonts'
        ,
          src: 'node_modules/assurance/build/assurance.js'
          dest: out_dev + 'js/assurance.js'
        ,
          src: 'node_modules/async/lib/async.js'
          dest: out_dev + 'js/async.js'
        ,
          src: 'node_modules/humanize-plus/public/src/humanize.js'
          dest: out_dev + 'js/humanize.js'
        ,
          src: 'bower_components/safejson/dist/safejson.js'
          dest: out_dev + 'js/safejson.js'
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
          cwd: 'bower_components/font-awesome/fonts'
          src: '*'
          dest: out + 'fonts'
        ,
          src: 'node_modules/assurance/build/assurance.min.js'
          dest: out + 'js/assurance.js'
        ,
          src: 'node_modules/async/lib/async.js'
          dest: out + 'js/async.js'
        ,
          src: 'node_modules/humanize-plus/public/src/humanize.js'
          dest: out + 'js/humanize.js'
        ,
          src: 'bower_components/safejson/dist/safejson.min.js'
          dest: out + 'js/safejson.js'
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
        ]

    concat:
      dev:
        files: [
          src: [
            'bower_components/lodash/dist/lodash.js'
            'node_modules/underscore.string/lib/underscore.string.js'
            'bower_components/jquery/dist/jquery.js'
            'bower_components/jquery-ui/ui/jquery-ui.js'
#            'bower_components/underscore/underscore.js'
            'bower_components/moment/moment.js'
            'bower_components/moment/lang/en_ca.js'
            'bower_components/moment/lang/fr.js'
            'bower_components/moment/lang/fr_ca.js'
            'bower_components/bootstrap/dist/js/bootstrap.js'
            'bower_components/angular/angular.js'
            'bower_components/angular-cookies/angular-cookies.js'
            'bower_components/angular-resource/angular-resource.js'
            'bower_components/angular-animate/angular-animate.js'
            'bower_components/angular-ui-router/release/angular-ui-router.js'
            'bower_components/i18next/i18next.js'
            'bower_components/ng-i18next/dist/ng-i18next.js'
            'bower_components/angular-promise-tracker/promise-tracker.js'
            'bower_components/select2/select2.js'
            'bower_components/ng-table/ng-table.js'
            'bower_components/angular-ui/build/angular-ui.js'
            'bower_components/angular-dragdrop/src/angular-dragdrop.js'
            'bower_components/eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min.js'
            'bower_components/jQuery-Mask-Plugin/jquery.mask.js'
            'bower_components/angular-webstorage/angular-webstorage.js'
            'bower_components/jquery-switchbutton/jquery.switchButton.js'
            'bower_components/angular-bootstrap/ui-bootstrap-tpls.js'
            'bower_components/multiselect/js/jquery.multi-select.js'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.js'
            'bower_components/angular-filters/dist/angular-filters.js'
            'bower_components/angular-lodash/angular-lodash.js'
            'bower_components/angular-underscore-string/angular-underscore-string.js'
            'bower_components/jquery-sortable/source/js/jquery-sortable.js'
            'bower_components/tinycolor/tinycolor.js'
            'bower_components/acorn/acorn.js'
            'bower_components/requirejs/require.js'
            tmp_dev + '/dynFormTemplates.js'
          ]
          dest: out_dev + 'js/vendor.js'
        ,
          src: [
            'bower_components/lodash/dist/lodash.js'
            'node_modules/underscore.string/lib/underscore.string.js'
            'bower_components/jquery/dist/jquery.js'
            'bower_components/jquery-ui/ui/jquery-ui.js'
            'bower_components/safejson/dist/safejson.js'
#            'bower_components/underscore/underscore.js'
            'bower_components/moment/moment.js'
            'node_modules/color/color-0.6.0.js'
            'bower_components/bootstrap/dist/js/bootstrap.js'
            'bower_components/i18next/i18next.js'
            'bower_components/select2/select2.js'
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
            'bower_components/angular-ui-tree/dist/angular-ui-tree.min.css'
          ]
          dest: out_dev + 'css/vendor.css'
        ]

      prod:
        files: [
          src: [
            'bower_components/lodash/dist/lodash.min.js'
            'node_modules/underscore.string/dist/underscore.string.min.js'
            'bower_components/jquery/dist/jquery.min.js'
            'bower_components/jquery-ui/ui/minified/jquery-ui.min.js'
#            'bower_components/underscore/underscore.js'
            'bower_components/safejson/dist/safejson.min.js'
            'bower_components/moment/min/moment-with-langs.min.js'
            'bower_components/bootstrap/dist/js/bootstrap.min.js'
            'bower_components/angular/angular.min.js'
            'bower_components/angular-cookies/angular-cookies.min.js'
            'bower_components/angular-resource/angular-resource.min.js'
            'bower_components/angular-animate/angular-animate.min.js'
            'bower_components/angular-ui-router/release/angular-ui-router.min.js'
            'bower_components/i18next/i18next.min.js'
            'bower_components/ng-i18next/dist/ng-i18next.min.js'
            'bower_components/angular-promise-tracker/promise-tracker.js'
            'bower_components/select2/select2.min.js'
            'bower_components/ng-table/ng-table.min.js'
            'bower_components/angular-ui/build/angular-ui.min.js'
            'bower_components/angular-dragdrop/src/angular-dragdrop.min.js'
            'bower_components/eonasdan-bootstrap-datetimepicker/build/js/bootstrap-datetimepicker.min.js'
            'bower_components/jQuery-Mask-Plugin/jquery.mask.min.js'
            'bower_components/angular-webstorage/angular-webstorage.js'
            'bower_components/jquery-switchbutton/jquery.switchButton.js'
            'bower_components/angular-bootstrap/ui-bootstrap-tpls.min.js'
            'bower_components/multiselect/js/jquery.multi-select.js'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.min.js'
            'bower_components/angular-filters/dist/angular-filters.min.js'
            'bower_components/angular-lodash/angular-lodash.js'
            'bower_components/angular-underscore-string/angular-underscore-string.js'
            'bower_components/jquery-sortable/source/js/jquery-sortable.min.js'
            'bower_components/tinycolor/tinycolor.js'
            'bower_components/acorn/acorn.js'
            'bower_components/requirejs/require.js'
            tmp + '/dynFormTemplates.js'
          ]
          dest: out + 'js/vendor.js'
        ,
          src: [
            'bower_components/lodash/dist/lodash.min.js'
            'node_modules/underscore.string/dist/underscore.string.min.js'
            'bower_components/jquery/dist/jquery.min.js'
            'bower_components/jquery-ui/ui/jquery-ui.min.js'
            'bower_components/safejson/dist/safejson.min.js'
#            'bower_components/underscore/underscore.js'
            'bower_components/moment/moment-with-langs.min.js'
            'node_modules/color/color-0.6.0.min.js'
            'bower_components/bootstrap/dist/js/bootstrap.min.js'
            'bower_components/i18next/i18next.min.js'
            'bower_components/select2/select2.min.js'
            'bower_components/requirejs/require.js'
          ]
          dest: out + 'js/index.js'
        ,
          src: [
            'bower_components/select2/select2.css'
            'bower_components/eonasdan-bootstrap-datetimepicker/build/css/bootstrap-datetimepicker.min.css'
            'bower_components/yamm3/yamm/yamm.css'
            'bower_components/jquery-ui/themes/base/minified/jquery-ui.min.css'
            'bower_components/ng-table/ng-table.css'
            'bower_components/angular-ui/build/angular-ui.min.css'
            'bower_components/jquery-switchbutton/jquery.switchButton.css'
            'bower_components/multiselect/css/multi-select.css'
            'bower_components/angular-ui-tree/dist/angular-ui-tree.min.css'
          ]
          dest: out + 'css/vendor.css'
        ]

    "file-creator":
      options:
        openFlags: 'w'

      dev:
        "{tmp}dynFormTemplates.js": (fs, fd, done) ->
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

    watch:
      options:
        spawn: false
        livereload: true
        debounceDelay: 1000

      gruntfile:
        files: ['Gruntfile.coffee']
        tasks: ['default']
        options:
          interrupt: true
          reload: true

      jade:
        files: ['app/**/*.jade']
        tasks: ['jade:dev', 'reload']

      jadeDynForm:
        files: ['app/dynFormTemplates/*.jade']
        tasks: ['jade:dev', 'jade:devDynForm', 'file-creator:dev', 'concat:dev', 'reload']

      server_jade:
        files: ['server/**/*.jade']
        tasks: ['copy:server_dev', 'reload']

      less:
        files: ['app/**/*.less']
        tasks: ['less:dev', 'reload']

      coffee:
        files: ['app/**/*.coffee']
        tasks: ['coffee:dev', 'concat:dev', 'copy:dev', 'reload']

      server_coffee:
        files: ['server/**/*.coffee']
        tasks: ['coffee:server_dev', 'copy:server_dev', 'express:dev', 'reload']

      global_coffee:
        files: ['scripts/**/*.coffee']
        tasks: ['coffee:server_dev', 'copy:server_dev', 'coffee:dev', 'concat:dev', 'copy:dev', 'express:dev', 'reload']

      js:
        files: ['app/**/*.js', 'server/**/*.js']
        tasks: ['concat:dev', 'copy:dev', 'reload']

      server_js:
        files: ['server/**/*.js']
        tasks: ['copy:server_dev']

      html:
        files: ['app/**/*.html', 'server/**/*.html']
        tasks: ['reload']

      server_config:
        files: ['server/config/**']
        tasks: ['coffee:server_dev', 'copy:server_dev', 'express:dev', 'reload']

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

#    curl:
#      dev: 'http://localhost:35729/changed?files=/js/app.js'

#    open:
#      dev:
#        path: 'http://localhost:3000'
#        app: '/Applications/Firefox.app'
  )

  d = grunt.config.data['file-creator'].dev
  if d
    for k of d
      d[k.replace(/\{tmp\}/g, tmp_dev)] = d[k]
      delete d[k]

  d = grunt.config.data['file-creator'].prod
  if d
    for k of d
      d[k.replace(/\{tmp\}/g, tmp)] = d[k]
      delete d[k]

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

  #  Default task(s).
  grunt.registerTask('default', ['clean:server_dev', 'coffee:server_dev', 'copy:server_dev', 'clean:dev', 'less:dev', 'coffee:dev', 'copy:dev', 'jade:dev', 'jade:devDynForm', 'file-creator:dev', 'concat:dev', 'express:dev', 'reload', 'watch'])

  grunt.registerTask('prod', ['clean:server_prod', 'coffee:server_prod', 'copy:server_prod', 'clean:prod', 'less:prod', 'coffee:prod', 'copy:prod', 'jade:prod', 'jade:prodDynForm', 'file-creator:prod', 'concat:prod'])
