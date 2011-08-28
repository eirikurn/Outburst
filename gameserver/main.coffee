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
    @isGameOver = false
    @spawnTimer = 0
    @remainingSpawns = 0
    @entityIds = 1000
    @playerIds = 0

    @tickTimer = setInterval @tick, 1000 / constants.TICKS_PER_SECOND

  player_connect: (socket) ->
    utils.addCompression socket

    startX = Math.random() * 400 - 200
    startY = Math.random() * 400 - 200
    state = new states.PlayerState x: startX, y: startY, id: ++@playerIds, seed: (+new Date + @playerIds)
    # console.log state
    player = new Player(socket, state)
    @players.push player
    @states.head().players[state.id] = state

    socket.compressed.on 'input', (inputs) => @player_input player, inputs
    socket.on 'disconnect', => @player_disconnect player
    socket.on 'chat', (p) => @player_chat(socket, p)
    socket.on 'nick', (n) => @player_nick(player, n)
    socket.compressed.emit "welcome", player: state, clock: +new Date / 1000

  player_disconnect: (player) ->
    index = @players.indexOf player
    if index != -1
      @players.splice index, 1

  player_input: (player, data) ->
    player.inputs.push v for k, v of data when k != "count"
    
  player_chat: (socket, packets) ->
    @chatlog.push p for p in packets
    @chatlog.shift() if @chatlog.length > 8
    socket.broadcast.emit 'chat', packets
    
  player_nick: (player, nick) ->
    if player.state.nick
      player.socket.broadcast.emit "chat", [ player: "server", msg: player.state.nick + " is now called " + nick]
    else
      player.socket.emit "chat", [ player: "server", msg: "Welcome to Outburst, gl n hf!"].concat @chatlog
      player.socket.broadcast.emit "chat", [ player: "server", msg: nick + " joined the game"]
    player.state.nick = nick

  startGame: ->
    if @gameIsOver then return
    console.log "Game starting"
    @spawnTimer = constants.FIRST_WAVE
    state = @states.head()
    state.wave = 0
    state.lives = constants.START_LIVES
    @sheeps.length = 0

    for i in [1..state.lives]
      @spawnSheep()

    setTimeout =>
      @io.sockets.emit "chat", [ player: "server", msg: "Game starts in " + (constants.FIRST_WAVE - 2) + " seconds" ]
    , 2000
    
    setTimeout =>
      if @players.length
        @io.sockets.emit "chat", [ player: "server", msg: "Let the game begin!" ]
        @io.sockets.emit "start", {}
    , constants.FIRST_WAVE * 1000

  endGame: ->
    console.log "Game ending"
    @enemies.length = 0
    @spawnTimer = 0
    if @players.length
      setTimeout (=> @startGame()), 3000
      
  gameOver: ->
    console.log "Game over"
    @isGameOver = yes
    @enemies.length = 0
    @spawnTimer = 0
    @io.sockets.emit "chat", [ player: "server", msg: "GAME OVER :(" ]
    #@io.sockets.emit "gameover" 
    
    setTimeout =>
      @io.sockets.emit "chat", [ player: "server", msg: "Restarting in 10 seconds" ]
    , 5000
    
    setTimeout =>
      console.log "game no longer over"
      @isGameOver = no
      @startGame()
    , 10000
    
    

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
        state = @states.item(i.tick - world.tick - 1)
        newState.applyInput i, world, state
      p.inputs.length = 0
      world.players[newState.id] = p.state = newState
    return

  updateEnemies: (world) ->
    for e in @enemies
      state = e.onTick()
      if state
        world.enemies[state.id] = state if state
      else
        if @sheeps.length > 0
          @sheeps.pop() # DIE DIE
    return
  
  updateSheep: (world) ->
    for s in @sheeps
      state = s.onTick()
      world.sheeps[state.id] = state if state
    return

  # The main "Game Loop"
  tick: =>
    if not @gameOver
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
    
    if @sheeps.length == 0 and not @isGameOver
      @gameOver()

    time = +new Date / 1000
    world = @states.new(timestamp: time)
    @states.item(-2)?.clone(world)
    world.tick++

    @updatePlayers(world)
    @updateGame(world)
    @updateEnemies(world)
    @updateSheep(world)

    # Send updates to due players
    for p in @players
      if p.lastUpdate + constants.TIME_BETWEEN_UPDATES <= time
        p.lastUpdate = Math.max time, p.lastUpdate + constants.TIME_BETWEEN_UPDATES
        p.socket.compressed.emit 'world', world

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
