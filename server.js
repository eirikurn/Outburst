#!/usr/bin/env node

/**
 * Module dependencies.
 */

var coffee = require('coffee-script')
  , nko = require('nko')('Vzhctm/pgoeQd99c')
  , app = require('./app')
  , port = process.env.PORT || 8000;

app.listen(process.env.PORT || 8000);
console.log("Express server listening on port %d in %s mode", port, app.settings.env);

