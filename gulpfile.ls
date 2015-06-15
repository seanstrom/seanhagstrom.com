metalsmith  = require 'metalsmith'
gulp        = require 'gulp'
rimraf      = require 'gulp-rimraf'
gulpsmith   = require 'gulpsmith'
path        = require 'path'
moment      = require 'moment'
highlighter = require 'highlight.js'
ghpages     = require 'gh-pages'

stylus      = require 'metalsmith-stylus'
serve       = require 'metalsmith-serve'
branch      = require 'metalsmith-branch'
markdown    = require 'metalsmith-markdown'
collections = require 'metalsmith-collections'
templates   = require 'metalsmith-templates'
excerpts    = require 'metalsmith-excerpts'
permalinks  = require 'metalsmith-permalinks'
watch       = require 'metalsmith-watch'

metadata =
  site:
    title: 'sean hagstrom'
    url: 'seanhagstrom.com'

pages-config = relative: false

essays-config =
  pattern: ':publishDate/:title'
  date: 'YYYY/MM/DD'

content-config =
  essays: 'essays/**.html'
  notEssays: '!essays/**.html'
  projects: 'projects/**.html'

collections-config =
  essays:
    pattern: content-config.essays
    sortBy: 'publishDate'
    reverse: true
  projects:
    pattern: content-config.projects
    sortBy: 'publishDate'
    reverse: true

marked-config =
  gfm: true
  smartypants: false
  highlight: (code) -> highlighter.highlightAuto(code).value

paths-config =
  paths:
    "${source}/**/*": true
    "templates/**/*": "**/*.jade"

log-status = (cond, succ-message, fail-message) ->
  if cond
  then console.log succ-message
  else console.log fail-message

buildSetup = -> (err) ->
  log-status !err, 'Built!', "Build Error: #{err}"

commonSteps = ->
  metalsmith(__dirname)
    .metadata metadata
    .source './src'
    .destination './build'
    .use stylus!
    .use excerpts!
    .use markdown marked-config
    .use collections collections-config
    .use templates engine: 'jade', moment: moment
    .use (branch('essays/**.html').use  <| permalinks <| essays-config)
    .use (branch('!essays/**.html').use <| branch('!index.md').use <| permalinks <| pages-config)

gulp.task 'build', ->
  commonSteps!
    .build buildSetup!

gulp.task 'serve', ->
  commonSteps!
    .use serve port: 8080, verbose: true
    .use paths |> watch
    .build buildSetup!

gulp.task 'clean', ->
  gulp.src './build', read: false
    .pipe rimraf!

gulp.task 'deploy', ['build'], ->
  dir = path.join(__dirname, 'build')
  ghpages.publish dir, (err) ->
    log-status !err, 'Deployed!', "Deploy Error: #{err}"
