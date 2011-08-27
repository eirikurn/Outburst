io = require('socket.io')

class exports.Server
  constructor: (app) ->
    @io = require('socket.io').listen app
    @io.set 'log level', 2

    @players = []
    @io.on 'connection', @player_connected

  player_connected: (socket) =>
    player = new Player(socket)
    @players.push player

    socket.on 'disconnect', => @player_disconnect player

  player_disconnected: (player) =>
    index = @players.indexOf player
    if index != -1
      @players.splice index, 1

