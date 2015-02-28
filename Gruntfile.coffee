module.exports = (grunt) ->
  grunt.initConfig
    coffee:
      compileJoined:
        options:
          join: true
        files:
          'password-entropy.js':
            [
              'src/*.coffee'
#             'otherdirectory/*.coffee'
            ]
    watch:
      files: 'src/*.coffee'
      tasks:
        [
          'coffee'
#         'other-task'
        ]

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['coffee']