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

    robot = new Enemy()
    @scene.addObject robot
    
    # Chat messages
    chat = new Chat(@socket)

  joinedServer: (data) =>
    @player = new Player(new states.PlayerState(data.player), @camera)
    @addEntity(data.player.id, @player)
    @user.username = "Anonymous " + data.player.id if @user.username == "Anonymous"
    @socket.emit 'nick', @user.username

  addEntity: (id, entity) ->
    @entities[id] = entity
    @scene.addObject entity
    
  addShot: (sourcePlayer, direction) ->
    shot = new Shot(sourcePlayer.position.x, sourcePlayer.position.y, direction)
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
        # TODO
        # @addEntity(e.id, new EnemyUnit(e))
      else
        @entities[e.id].addState(e)
    return

  onFrame: =>
    now = +new Date / 1000
    delta = now - @lastFrame
    @lastFrame = now
    
    @input.onFrame delta

    if @player
      # Capture input state
      while @lastTick + constants.TIME_PER_TICK <= now
        oneState = @input.getState()
        @inputs.push oneState
        @player.applyInput oneState
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
        twitterUser.username = twitterUser.screen_name
        initGame(twitterUser)
  else
    # Anonymous lame-o
    initGame()
      
      
initGame = (user = username: "Anonymous") ->
  window.game = new Game(user)
  

trace = (message) ->
  console?.log message

