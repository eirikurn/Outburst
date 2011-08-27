io = require('socket.io')

class exports.Server
  constructor: (app) ->
    io = require('socket.io').listen app
    io.set 'log level', 2


