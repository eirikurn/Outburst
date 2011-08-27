((exports)->
  constants = require './constants'

  class exports.UnitState
    constructor: (data) ->
      for k in @constructor.fields
        @[k] = data[k]

    clone: (target = new @constructor()) ->
      for k in @constructor.fields
        target[k] = @[k]

    @fields = ['x', 'y']

  class exports.PlayerState extends exports.UnitState
    applyInput: (input, target = @) ->
      target.x = @x + input.moveX * constants.PLAYER_SPEED
      target.y = @y + input.moveY * constants.PLAYER_SPEED

  class exports.WorldState
    constructor: (data) ->
      @players = []
      @enemies = []


)(if exports? then exports else window["state"] = {})
