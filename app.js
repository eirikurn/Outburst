
/**
 * Module dependencies.
 */

var express = require('express')
  , sys = require('sys')

/**
 * Create express server
 */
var app = module.exports = express.createServer();

/**
 * Game servers
 */
var GameServer = require('./gameserver/main');
new GameServer.Server(app);

/**
 * Master server
 */
var MasterServer = require('./masterserver/main');
new MasterServer.Server(app);

