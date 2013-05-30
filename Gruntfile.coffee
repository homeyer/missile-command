module.exports = (grunt) ->

    grunt.loadNpmTasks 'grunt-contrib-coffee'
    grunt.loadNpmTasks 'grunt-contrib-watch'

    grunt.registerTask 'default', ['coffee']

    grunt.initConfig

        watch:
            server:
                files: 'server/src/**/*.coffee'
                tasks: ['coffee:src']


        coffee:
            server:
                expand: true
                cwd: 'server/src/'
                src: ['**/*.coffee']
                dest: 'server/gen/js/src'
                ext: '.js'