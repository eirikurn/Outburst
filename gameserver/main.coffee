io = require('socket.io')
Player = require './player'
utils = require './shared/utils.coffee'
constants = require './shared/constants.coffee'
states = require './shared/states.coffee'

class exports.Server
  constructor: (app) ->
    @io = io.listen app,
      'transports': ['websocket']
      'log level': 2
    @io.sockets.on 'connection', (s) => @player_connect(s)

    stateCount = Math.round(constants.ROLLBACK_TIME * constants.TICKS_PER_SECOND) + 1
    @states = new utils.StatePool(states.WorldState, stateCount)
    @states.new(timestamp: +new Date / 1000)
    @chatlog = []
    @players = []
    @enemies = []
    @isStarted = false
    @spawnTimer = 0
    @remainingSpawns = 0
    @enemyIds = 0
    @playerIds = 0

    @tickTimer = setInterval @tick, 1000 / constants.TICKS_PER_SECOND

  player_connect: (socket) ->
    console.log "Player connected..."
    startX = Math.random() * 400 - 200
    startY = Math.random() * 400 - 200
    state = new states.PlayerState x: startX, y: startY, id: @playerIds++, seed: (+new Date + @playerIds)
    # console.log state
    player = new Player(socket, state)
    @players.push player
    @states.head().players.push state

    socket.on 'input', (inputs) => @player_input player, inputs
    socket.on 'disconnect', => @player_disconnect player
    socket.on 'chat', (p) => @player_chat(socket, p)
    socket.on 'nick', (n) => @player_nick(player, n)
    socket.emit "welcome", player: state, clock: +new Date / 1000

  player_disconnect: (player) ->
    index = @players.indexOf player
    if index != -1
      @players.splice index, 1

  player_input: (player, data) ->
    player.inputs.concat data
    Array::push.apply player.inputs, data
    
  player_chat: (socket, packets) ->
    @chatlog.push p for p in packets
    @chatlog.shift() if @chatlog.length > 8
    socket.broadcast.emit 'chat', packets
    
  player_nick: (player, nick) ->
    if player.nick
      player.socket.broadcast.emit "chat", [ player: "server", msg: player.nick + " is now called " + nick]
    else
      player.socket.emit "chat", [ player: "server", msg: "Welcome to Outburst, gl n hf!"].concat @chatlog
      player.socket.broadcast.emit "chat", [ player: "server", msg: nick + " joined the game"]
    player.nick = nick

  startGame: ->
    console.log "Game starting"
    @spawnTimer = constants.START_WAVE
    setTimeout =>
      @io.sockets.emit "chat", [ player: "server", msg: "Game starts in " + (constants.START_WAVE - 2) + " seconds" ]
    , 2000

  endGame: ->
    console.log "Game ending"
    @enemies.length = 0
    @spawnTimer = 0
    if @players.length
      setTimeout (=> @startGame()), 3000

  spawnEnemy: (wave) ->
    direction = Math.random() * Math.PI * 2
    distance = Math.random() * constants.MAP.weypointSize
    startX = constants.MAP.enemySpawn[0] + Math.sin(direction) * distance
    startY = constants.MAP.enemySpawn[1] + Math.cos(direction) * distance
    hp = constants.ENEMY_BASE_HP + constants.ENEMY_HP_PER_WAVE * wave
    new Enemy(x: startX, y: startY, hp: hp, waypointDistance: distance, waypointDirection: direction)

  updateGame: (world) ->
    @spawnTimer = Math.max(0, @spawnTimer - constants.TIME_PER_TICK)
    if not @spawnTimer and @remainingSpawns
      @spawnTimer = constants.WAVE_INTERVAL
      @enemies.push spawnEnemy()
      @remainingSpawns--
      if @remainingSpawns
        @spawnTimer = constants.SPAWN_RATE
      else
        @spawnTimer = constants.WAVE_INTERVAL

  # The main "Game Loop"
  tick: =>
    if not @isStarted
      if @players.length
        @isStarted = true
        @startGame()
      else
        return
    else if @players.length == 0
      @isStarted = false
      @endGame()

    time = +new Date / 1000
    world = @states.new(timestamp: time)

    # Process player inputs
    for p in @players
      newState = p.state.clone()
      for i in p.inputs
        newState.applyInput i
      p.inputs.length = 0
      world.players.push p.state = newState

    @updateGame()

    # Send updates to due players
    for p in @players
      if p.lastUpdate + constants.TIME_BETWEEN_UPDATES <= time
        p.lastUpdate = Math.max time, p.lastUpdate + constants.TIME_BETWEEN_UPDATES
        p.socket.emit 'world', world
