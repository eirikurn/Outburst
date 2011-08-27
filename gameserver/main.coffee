io = require('socket.io')
Player = require './player'
{RollingPool} = require './utils'
constants = require './shared/constants'
state = require './shared/state'

class exports.Server
  constructor: (app) ->
    @io = require('socket.io').listen app,
      'transports': ['websocket']
      'log level': 2
    @io.sockets.on 'connection', (s) => @player_connect(s)

    stateCount = Math.round(constants.ROLLBACK_TIME * constants.TICKS_PER_SECOND) + 1
    @states = new RollingPool(state.WorldState, stateCount)
    @states.get()
    @players = []

    @tickTimer = setInterval @tick, 1000 / constants.TICKS_PER_SEC

  player_connect: (socket) ->
    state = new state.PlayerState x: 0, y: 0
    player = new Player(socket, state)
    @players.push player
    @states.head().players.push state

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
    world = @states.get()
    for p in players
      newState = p.state.clone()
      for i in p.inputs
        newState.applyInput i
      world.players.push p.state




