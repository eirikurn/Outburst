class Game
  constructor: ->
    @lastFrame = +new Date / 1000
    @lastTick = +new Date / 1000
    @lastSentInputs = +new Date / 1000
    @inputs = []

    worldCount = constants.INTERPOLATE_FRAMES + 1
    @worlds = new utils.StatePool(states.WorldState, worldCount)

    @socket = io.connect()
    @socket.on 'welcome', @joinedServer
    @socket.on 'world', @updateFromServer

    @initRenderer()
    @initGraphics()
    @initStats()
    window.input = @input = new Input @camera, @map.map
    @onFrame()

  joinedServer: (data) =>
    console.log data
    @player = new Player(new states.PlayerState(data.player), @camera)
    @addEntity(data.player.id, @player)

  addEntity: (id, entity) ->
    @entities[id] = entity
    @scene.addObject entity

  updateFromServer: (data) =>
    world = @worlds.new data
    for p in world.players# when p.id != @player.id
      if not @entities[p.id]
        @addEntity(p.id, new PlayerUnit(p))
      else
        @entities[p.id].addState(p)
    return

  onFrame: =>
    now = +new Date / 1000
    delta = now - @lastFrame
    @lastFrame = now

    # Capture input state
    while @lastTick + constants.TIME_PER_TICK <= now
      @inputs.push @input.getState()
      @lastTick += constants.TIME_PER_TICK

    # Send input to server
    if @lastSentInputs + constants.TIME_BETWEEN_INPUTS <= now
      @socket.emit 'input', @inputs
      @inputs.length = 0
      @lastSentInputs += constants.TIME_BETWEEN_INPUTS

    # Update entities
    for k, e of @entities
      e.onFrame(delta) if e.onFrame

    @renderer.render @scene, @camera
    @cursor.onFrame()
    @stats.update()

    requestAnimFrame(@onFrame, @container)

  initGraphics: ->

    @scene = new THREE.Scene()
    @camera = new Camera(@targetWidth, @targetHeight)
    @entities = {}

    @scene.addChild @map = new Map()
    @scene.addChild @cursor = new Cursor()

  initRenderer: ->
    @targetWidth = 1024
    @targetHeight = 576

    @renderer = new THREE.WebGLRenderer()
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

document.addEventListener 'DOMContentLoaded', ->
  window.game = new Game()

  # Chat messages
  chat = new Chat()

trace = (message) ->
  console?.log message

