gulp        = require 'gulp'
metalsmith  = require 'metalsmith'
gulpsmith   = require 'gulpsmith'
moment      = require 'moment'
highlighter = require 'highlight.js'
ghpages     = require 'gh-pages'
path        = require 'path'

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

content =
  essays: 'essays/**.html'
  notEssays: '!essays/**.html'
  projects: 'projects/**.html'

essayConfig =
  pattern: ':publishDate/:title'
  date: 'YYYY/MM/DD'

collectionsConfig =
  essays:
    pattern: content.essays
    sortBy: 'publishDate'
    reverse: true
  projects:
    pattern: content.projects
    sortBy: 'publishDate'
    reverse: true

markedConfig =
  gfm: true
  smartypants: false
  highlight: (code) -> highlighter.highlightAuto(code).value

collectionsSetup = -> collections collectionsConfig

essaysSetup = -> branch('essays/**.html').use <| permalinks <| essayConfig

pagesSetup = -> branch('!essays/**.html').use <| branch('!index.md').use <| permalinks <| relative: false

templatesSetup = -> templates engine: 'jade', moment: moment

serveSetup = -> serve port: 8080, verbose: true

watchSetup = ->
  paths =
    paths:
      "${source}/**/*": true
      "templates/**/*": "**/*.jade"
  paths |> watch

buildSetup = -> (err) ->
  if err
    console.log err
  else
    console.log 'Site build complete!'

gulp.task 'build', ->
  metalsmith(__dirname)
    .metadata metadata
    .source './src'
    .destination './build'
    .use stylus!
    .use markdown markedConfig
    .use excerpts!
    .use collectionsSetup!
    .use essaysSetup!
    .use pagesSetup!
    .use templatesSetup!
    .build buildSetup!

gulp.task 'serve', ->
  metalsmith(__dirname)
    .metadata metadata
    .source './src'
    .destination './build'
    .use stylus!
    .use markdown markedConfig
    .use excerpts!
    .use collectionsSetup!
    .use essaysSetup!
    .use pagesSetup!
    .use templatesSetup!
    .use serveSetup!
    .use watchSetup!
    .build buildSetup!

gulp.task 'deploy', ['build'], ->
  ghpages.publish path.join(__dirname, 'build'), (err) ->
    console.log(err)
