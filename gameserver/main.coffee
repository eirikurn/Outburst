require './threejs'
io = require('socket.io')
Player = require './player'
Enemy = require './enemy'
Sheep = require './sheep'
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
    @sheeps = []
    @isStarted = false
    @spawnTimer = 0
    @remainingSpawns = 0
    @enemyIds = 1000
    @playerIds = 0

    for i in [1..3]
      @spawnSheep()

    @tickTimer = setInterval @tick, 1000 / constants.TICKS_PER_SECOND

  player_connect: (socket) ->
    startX = Math.random() * 400 - 200
    startY = Math.random() * 400 - 200
    state = new states.PlayerState x: startX, y: startY, id: ++@playerIds, seed: (+new Date + @playerIds)
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
    @spawnTimer = constants.FIRST_WAVE
    setTimeout =>
      @io.sockets.emit "chat", [ player: "server", msg: "Game starts in " + (constants.FIRST_WAVE - 2) + " seconds" ]
    , 2000

  endGame: ->
    console.log "Game ending"
    @enemies.length = 0
    @spawnTimer = 0
    if @players.length
      setTimeout (=> @startGame()), 3000

  updateGame: (world) ->
    @spawnTimer = Math.max(0, @spawnTimer - constants.TIME_PER_TICK)
    if @spawnTimer == 0
      if @remainingSpawns == 0
        ++world.wave
        @remainingSpawns = constants.ENEMIES_PER_WAVE
        console.log "Starting wave #{world.wave}"
      @spawnEnemy(world.wave)
      if --@remainingSpawns
        @spawnTimer = constants.SPAWN_RATE
      else
        @spawnTimer = constants.WAVE_INTERVAL

  updatePlayers: (world) ->
    for p in @players
      newState = p.state.clone()
      for i in p.inputs
        newState.applyInput i
      p.inputs.length = 0
      world.players.push p.state = newState
    return

  updateEnemies: (world) ->
    for e in @enemies
      state = e.onTick()
      world.enemies.push state if state
  
  updateSheep: (world) ->
    for s in @sheeps
      state = s.onTick()
      world.sheeps.push state if state

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
      return

    time = +new Date / 1000
    world = @states.new(timestamp: time)
    @states.item(-2)?.clone(world)

    @updatePlayers(world)
    @updateGame(world)
    @updateEnemies(world)
    @updateSheep(world)

    # Send updates to due players
    for p in @players
      if p.lastUpdate + constants.TIME_BETWEEN_UPDATES <= time
        p.lastUpdate = Math.max time, p.lastUpdate + constants.TIME_BETWEEN_UPDATES
        p.socket.emit 'world', world

  spawnEnemy: (wave) ->
    direction = Math.random() * Math.PI * 2
    distance = Math.random() * constants.MAP.waypointSize
    delta = [
      Math.sin(direction) * distance
      Math.cos(direction) * distance
    ]
    startX = constants.MAP.enemySpawn[0] + delta[0]
    startY = constants.MAP.enemySpawn[1] + delta[1]
    hp = constants.ENEMY_BASE_HP + constants.ENEMY_HP_PER_WAVE * wave

    enemy = new Enemy(x: startX, y: startY, hp: hp, id: ++@entityIds, waypointDelta: delta)
    @enemies.push enemy
    return enemy
  
  spawnSheep: ->
    direction = Math.random() * Math.PI * 2
    distance = Math.random() * constants.MAP.waypointSize
    delta = [
      Math.sin(direction) * distance
      Math.cos(direction) * distance
    ]
    startX = constants.MAP.base[0] + delta[0]
    startY = constants.MAP.base[1] + delta[1]
    sheep = new Sheep( x: startX, y: startY, hp: constants.SHEEP_HEALTH, id: ++@entityIds, direction: Math.random() * Math.PI * 2)
    @sheeps.push sheep
