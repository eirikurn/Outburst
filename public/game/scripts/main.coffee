class Game
  constructor: ->
    @lastFrame = +new Date / 1000
    @lastTick = +new Date / 1000
    @lastSentInputs = +new Date / 1000
    @inputs = []

    @socket = io.connect()
    @socket.on 'welcome', (data) ->

    window.input = @input = new Input()
    @world = new World()
    @initStats()
    @onFrame()

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

    @world.update(delta)
    @world.render()
    @stats.update()

    requestAnimFrame(@onFrame, @world.container)

  initStats: ->
    @stats = new Stats()
    @stats.domElement.style.position = 'absolute'
    @stats.domElement.style.top = '0px'
    @stats.domElement.style.zIndex = 100
    document.getElementById('container').appendChild(@stats.domElement)

document.addEventListener 'DOMContentLoaded', ->
  @game = new Game()

trace = (message) ->
  console?.log message

# A simple require implementation
require = (module) ->
  match = /^(\.\/)?(.+)$/.exec m
  module = match[2].split '/'
  obj = window
  obj = obj[stub] for stub in module
  return obj

