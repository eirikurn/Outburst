#!/usr/bin/env node

/**
 * Module dependencies.
 */

var cluster = require('cluster')
  , coffee = require('coffee-script')
  , nko = require('nko')('Vzhctm/pgoeQd99c')
  , app = require('./app')
  , port = process.env.PORT || 8000;

var cluster = cluster(app)
  .use(cluster.logger('logs'))
  .use(cluster.stats())
  .use(cluster.pidfiles('pids'))
  .use(cluster.cli())
  .in('development').use(cluster.reload(['server', 'app.js', 'server.js'], { extensions: ['.js', '.coffee'] }))
  .in('all')
    .listen(process.env.PORT || 8000);

if (cluster.isMaster) {
  console.log("Express server listening on port %d in %s mode", port, app.settings.env);
}

