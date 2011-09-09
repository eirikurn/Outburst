
/**
 * Module dependencies.
 */

var express = require('express')
  , sys = require('sys')
  , io = require('socket.io');

/**
 * Create express server
 */
var app = module.exports = express.createServer();

var io = io.listen(app, {
  'transports': ['websocket'],
  'log level': 2
});

/**
 * Game servers
 */
var GameServer = require('./gameserver/main');
new GameServer.Server(io);

/**
 * Master server
 */
var MasterServer = require('./masterserver/main');
new MasterServer.Server(app);

