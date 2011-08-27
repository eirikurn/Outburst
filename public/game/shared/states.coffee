((exports)->
  constants = require './constants'

  class exports.State
    constructor: ->
      if arguments[0] != false
        @init.apply this, arguments

    init: ->

  class exports.UnitState extends exports.State
    init: (data = {}) ->
      for k in @constructor.fields
        @[k] = data[k]

    clone: (target = new @constructor()) ->
      for k in @constructor.fields
        target[k] = @[k]
      target

    @fields = ['x', 'y', 'id']

  class exports.PlayerState extends exports.UnitState
    init: ->
      @walkDirection = 0
      @aimDirection = 0
      super

    applyInput: (input, target = @) ->
      velocity = constants.PLAYER_SPEED * constants.TIME_PER_TICK
      deltaX = 0; deltaY = 0
      deltaX += velocity if input.right
      deltaX -= velocity if input.left
      deltaY += velocity if input.up
      deltaY -= velocity if input.down
      if deltaX and deltaY
        deltaX *= 0.707106781
        deltaY *= 0.707106781

      target.x = @x + deltaX
      target.y = @y + deltaY
      target.walkDirection =
        if deltaX or deltaY
          Math.atan2(deltaY, deltaX)
        else
          @walkDirection
      target.aimDirection = Math.atan2(input.mouseY, input.mouseX)
      target

    @fields = ['x', 'y', 'id', 'walkDirection', 'aimDirection']

  class exports.WorldState extends exports.State
    init: (data = {}) ->
      @timestamp = data.timestamp
      @players = (new exports.PlayerState(p) for p in data.players or [])

)(if exports? then exports else window["states"] = {})
