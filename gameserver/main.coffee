io = require('socket.io')
Player = require './player'
{RollingPool} = require './utils'
constants = require './shared/constants'

class exports.Server
  constructor: (app) ->
    @io = require('socket.io').listen app,
      'transports': ['websocket']
      'log level': 2

    @states = new RollingPool()
    @players = []
    @io.sockets.on 'connection', (s) => @player_connect(s)

    @tickTimer = setInterval @tick, constants.TIME_PER_TICK * 1000

  player_connect: (socket) ->
    state = new state.PlayerState x: 0, y: 0
    player = new Player(socket, state)
    @players.push player

    socket.on 'input', (data) => @player_input player, data
    socket.on 'disconnect', => @player_disconnect player
    socket.emit "welcome", player

  player_disconnect: (player) ->
    index = @players.indexOf player
    if index != -1
      @players.splice index, 1

  player_state: (data) ->
    player.inputs.push data

  tick: ->


