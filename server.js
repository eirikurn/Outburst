#!/usr/bin/env node

var coffee = require('coffee-script')
  , app = require('./app')
  , port = process.env.PORT || 8000;

app.listen(port);
console.log("Listening on port %d in %s mode", port, app.settings.env);
