fs = require 'fs'
which = require 'which'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

build = (callback) ->
  options = [
    '-c'
    '-b'
    '--no-header'
    '-o'
    'scripts'
    'src'
  ]

  cmd = which.sync 'coffee'
  coffee = spawn cmd, options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  coffee.on 'exit', (status) ->
    # if status is not 0
    files = fs.readdirSync 'scripts'
    fs.renameSync('scripts/'+file, 'bin/'+file.replace('.js', '')) for file in files
    bins = fs.readdirSync 'bin'
    fs.chmodSync('bin/'+bin, '755') for bin in bins
    callback

# task 'dev', 'Start Dev Environment', ->
#   # Watch CoffeeScript File Changes
#   options = [
#     '-c'
#     '-b'
#     '-w'
#     '--no-header'
#     'bin'
#     'scripts'
#   ]
#
#   cmd = which.sync 'coffee'
#
#   coffee = spawn cmd, options
#   coffee.stdout.pipe process.stdout
#   coffee.stderr.pipe process.stderr
#
#   log 'Watching CoffeeScript files', green
#
#   # Watch for JavaScript file changes
#   nodemon = spawn 'iojs', [
#     './node_modules/nodemon/bin/nodemon.js',
#     '-w',
#     '.app',
#     '-e',
#     'js',
#     'server.js'
#   ]
#
#   nodemon.stdout.pipe process.stdout
#   nodemon.stderr.pipe process.stderr
#
#   log 'Watching JavaScript files and running server', green

task 'build', ->
  build -> log 'Build complete', green

task 'clean', ->
  clean -> log 'Clean complete', green

task 'rebuild', ->
  clean -> build -> log 'Rebuild complete', green
