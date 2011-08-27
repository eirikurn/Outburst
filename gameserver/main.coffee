io = require('socket.io')
Player = require './player'
{RollingPool} = require './utils'
constants = require './shared/constants'
states = require './shared/state'

class exports.Server
  constructor: (app) ->
    @io = require('socket.io').listen app,
      'transports': ['websocket']
      'log level': 2
    @io.sockets.on 'connection', (s) => @player_connect(s)

    stateCount = Math.round(constants.ROLLBACK_TIME * constants.TICKS_PER_SECOND) + 1
    @states = new RollingPool(states.WorldState, stateCount)
    @states.get()
    @players = []

    @tickTimer = setInterval @tick, 1000 / constants.TICKS_PER_SECOND

  player_connect: (socket) ->
    state = new states.PlayerState x: 0, y: 0
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

  # The main "Game Loop"
  tick: =>
    time = +new Date() / 1000
    world = @states.get(time)

    # Process player inputs
    for p in @players
      newState = p.state.clone()
      for i in p.inputs
        newState.applyInput i
      world.players.push p.state

    # Send updates to due players
    for p in @players
      if p.lastUpdate + constants.TIME_BETWEEN_UPDATES > time
        p.lastUpdate += constants.TIME_BETWEEN_UPDATES
        p.socket.emit 'world', world

