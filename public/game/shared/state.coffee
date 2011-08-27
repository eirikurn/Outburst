((exports)->

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
      target.x = @x + input.moveX
      target.y = @y + input.moveY


)(if exports? then exports else window["state"] = {})
