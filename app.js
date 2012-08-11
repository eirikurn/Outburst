
/**
 * Module dependencies.
 */

var express = require('express')
  , sys = require('sys')
  , io = require('socket.io')
  , socketPort = require('./gameserver/shared/constants').SOCKET_PORT;

/**
 * Create express server
 */
var app = module.exports = express.createServer();

if (!socketPort)
  socketPort = app;

var io = io.listen(socketPort, {
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

