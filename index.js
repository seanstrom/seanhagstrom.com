var metalsmith = require('metalsmith'),
  branch = require('metalsmith-branch'),
  collections = require('metalsmith-collections'),
  excerpts = require('metalsmith-excerpts'),
  markdown = require('metalsmith-markdown'),
  stylus = require('metalsmith-stylus'),
  permalinks = require('metalsmith-permalinks'),
  serve = require('metalsmith-serve'),
  templates = require('metalsmith-templates'),
  watch = require('metalsmith-watch'),
  moment = require('moment');

var metadata = {
  site: {
    title: 'sean hagstrom',
    url: 'seanhagstrom.com'
  }
}

var markedConfig = {
  gfm: true,
  smartypants: false,
  highlight: function(code) {
    return require('highlight.js').highlightAuto(code).value;
  }
}

var collectionsConfig = {
  posts: {
    pattern: 'essays/**.html',
    sortBy: 'publishDate',
    reverse: true
  }
}

var collectionsSetup = function() {
  return collections(collectionsConfig)
}

var postsSetup = function() {
  return branch('essays/**.html')
    .use(permalinks({
      pattern: ':publishDate/:title',
      date: 'YYYY/MM/DD'
    }));
}

var pagesSetup = function() {
  return branch('!essays/**.html')
    .use(branch('!index.md')
         .use(permalinks({
           relative: false
         })))
}

var templatesSetup = function() {
  return templates({
    engine: 'jade',
    moment: moment
  })
}

var serveSetup = function() {
  return serve({
    port: 8080,
    verbose: true
  })
}

var watchSetup = function() {
  return watch({
    paths: {
      "${source}/**/*": true,
      "templates/**/*": "**/*.jade",
    }
  })
}

var buildSetup = function() {
  return function (err) {
    if (err) {
      console.log(err);
    }
    else {
      console.log('Site build complete!');
    }
  }
}

metalsmith(__dirname)
  .metadata(metadata)
  .source('./src')
  .destination('./build')
  .use(stylus())
  .use(markdown(markedConfig))
  .use(excerpts())
  .use(collectionsSetup())
  .use(postsSetup())
  .use(pagesSetup())
  .use(templatesSetup())
  .use(serveSetup())
  .use(watchSetup())
  .build(buildSetup());
