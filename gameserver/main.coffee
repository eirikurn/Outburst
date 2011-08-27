io = require('socket.io')
Player = require './player'

class exports.Server
  constructor: (app) ->
    @io = require('socket.io').listen app
    # @io.set 'log level', 2

    @players = []
    @io.sockets.on 'connection', @player_connect

  player_connect: (socket) =>
    player = new Player(socket)
    @players.push player

    socket.on 'disconnect', => @player_disconnect player
    socket.emit "welcome", player

  player_disconnect: (player) ->
    index = @players.indexOf player
    if index != -1
      @players.splice index, 1

