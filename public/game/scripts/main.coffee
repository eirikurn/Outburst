class Game
  constructor: (@user)->
    @lastFrame = +new Date / 1000
    @lastTick = +new Date / 1000
    @lastSentInputs = +new Date / 1000
    @inputs = []
    @renderShots = []

    worldCount = constants.INTERPOLATE_FRAMES + 1
    @worlds = new utils.StatePool(states.WorldState, worldCount)

    @socket = io.connect()
    @socket.on 'welcome', @joinedServer
    @socket.on 'world', @updateFromServer

    @initRenderer()
    @initGraphics()
    @initStats() if constants.DISPLAY_STATS
    window.input = @input = new Input @camera, @map.map
    @onFrame()
    
    # ZERO ball
    ball = new THREE.Mesh(new THREE.SphereGeometry(10, 10, 10), new THREE.MeshLambertMaterial(color: 0xFF0000))
    ball.position.x = 0
    ball.position.y = 0
    @scene.addChild ball
    
    # Create the upper demo ball
    ball = new THREE.Mesh(new THREE.SphereGeometry(100, 10, 10), new THREE.MeshLambertMaterial(color: 0xFFFFFF))
    ball.position.x = -1000
    ball.position.y = 10
    @scene.addChild ball
    
    # Create the lower demo ball
    ball = new THREE.Mesh(new THREE.SphereGeometry(100, 10, 10), new THREE.MeshLambertMaterial(color: 0xFFFFFF))
    ball.position.x = 500
    ball.position.y = 600
    @scene.addChild ball
    
    # Chat messages
    chat = new Chat(@socket)

  joinedServer: (data) =>
    @player = new Player(new states.PlayerState(data.player), @camera)
    @addEntity(data.player.id, @player)
    @user.nick = "Anonymous " + data.player.id if @user.nick == "Anonymous"
    @player.state.nick = @user.nick
    @socket.emit 'nick', @user.nick

  addEntity: (id, entity) ->
    @entities[id] = entity
    @scene.addObject entity
    
  addShot: (sourcePlayer, state) ->
    shot = new Shot(state)
    @scene.addObject shot
    @renderShots.push shot

  updateFromServer: (data) =>
    world = @worlds.new data
    for p in world.players# when p.id != @player.id
      if not @entities[p.id]
        @addEntity(p.id, new PlayerUnit(p))
      else
        @entities[p.id].addState(p)

    for e in world.enemies
      if not @entities[e.id]
        @addEntity(e.id, new Enemy(e))
      else
        @entities[e.id].addState(e)

    for s in world.sheeps
      if not @entities[s.id]
        @addEntity(s.id, new Sheep(s))
      else
        @entities[s.id].addState(s)

    @removeNullEntities(world)
  
  removeNullEntities: (world) ->
    worldEntityIds = (wEntity.id.toString() for wEntity in world.players.concat world.sheeps, world.enemies)
    for localId of @entities
      if localId not in worldEntityIds
        @scene.removeChild @entities[localId]
        delete @entities[localId]

  onFrame: =>
    now = +new Date / 1000
    delta = now - @lastFrame
    @lastFrame = now
    
    @input.onFrame delta

    if @player and @worlds.head()
      world = @worlds.head()
      # Capture input state
      while @lastTick + constants.TIME_PER_TICK <= now
        oneState = @input.getState()
        oneState.tick = world.tick
        @player.applyInput oneState, world

        @inputs.push oneState
        @lastTick += constants.TIME_PER_TICK

      # Send input to server
      if @lastSentInputs + constants.TIME_BETWEEN_INPUTS <= now
        @socket.emit 'input', @inputs
        @inputs.length = 0
        @lastSentInputs += constants.TIME_BETWEEN_INPUTS

    # Update entities
    for k, e of @entities
      e.onFrame(delta) if e.onFrame
    
    # Update shots
    for shot in @renderShots
      shot.onFrame delta
      if not shot.isAlive
        @scene.removeObject shot
      
    # Discard dead shots, TODO: Factory, pool
    @renderShots = (shot for shot in @renderShots when shot.isAlive)
    
    @camera.onFrame()
    @renderer.render @scene, @camera
    @cursor.onFrame()
    @stats.update() if constants.DISPLAY_STATS

    requestAnimFrame(@onFrame, @container)

  initGraphics: ->

    @scene = new THREE.Scene()
    @camera = new Camera(@targetWidth, @targetHeight)
    @entities = {}
    
    @scene.addChild @map = new Map()
    @scene.addChild @cursor = new Cursor()
    @hud = new Hud()

  initRenderer: ->
    @targetWidth = 1024
    @targetHeight = 576

    @renderer = new THREE.WebGLRenderer({ antialias: true })
    @renderer.setSize(@targetWidth, @targetHeight)
    @renderer.setClearColorHex 0xFFFFFF
    wrapper = document.getElementById 'wrapper'
    wrapper.style.width = @targetWidth + 'px'
    wrapper.style.height = @targetHeight + 'px'
    @container = document.getElementById 'container'
    @container.style.width = @targetWidth + 'px'
    @container.style.height = @targetHeight + 'px'
    @container.appendChild(@renderer.domElement)

    window.addEventListener 'resize', => @resizeToFit()
    @resizeToFit()

  resizeToFit: ->
    setWidth = window.innerWidth
    setHeight = Math.floor setWidth * (@targetHeight / @targetWidth)

    if setWidth > window.innerWidth
      setWidth = window.innerWidth
      setHeight = Math.floor setWidth * (@targetHeight / @targetWidth)

    if setHeight > window.innerHeight - 3
      setHeight = window.innerHeight - 3
      setWidth = Math.floor setHeight * (@targetWidth / @targetHeight)

    @renderer.setSize setWidth, setHeight
    @container.style.width = setWidth + "px"
    @container.style.height = setHeight + "px"

  initStats: ->
    @stats = new Stats()
    @stats.domElement.style.position = 'absolute'
    @stats.domElement.style.top = '0px'
    @stats.domElement.style.zIndex = 100
    document.getElementById('container').appendChild(@stats.domElement)

document.addEventListener 'DOMContentLoaded', =>
  # If user was just redirected from twitter
  if document.location.href.indexOf("loggedIn") != -1
    # Try to authenticate user
    microAjax "/oauth/user", (res) ->
      if res == "error" 
        window.location = "/oauth/authenticate"
      else
        twitterUser = JSON.parse res
        initGame(nick: twitterUser.screen_name)
  else
    # Anonymous lame-o
    initGame()
      
      
initGame = (user = nick: "Anonymous") ->
  window.game = new Game(user)
  

trace = (message) ->
  console?.log message

