((exports)->
  constants = require './constants'

  class exports.UnitState
    constructor: (data) ->
      for k in @constructor.fields
        @[k] = data[k]

    clone: (target = new @constructor()) ->
      for k in @constructor.fields
        target[k] = @[k]

  exports.UnitState = ['x', 'y']

  class exports.PlayerState extends exports.UnitState
    applyInput: (input, target = @) ->
      target.x = @x + input.moveX * constants.PLAYER_SPEED
      target.y = @y + input.moveY * constants.PLAYER_SPEED


)(if exports? then exports else window["state"] = {})
