((exports)->
  constants = require './constants'

  class exports.State
    constructor: ->
      if arguments[0] != false
        @init.apply this, arguments

    init: ->

  class exports.UnitState extends exports.State
    init: (data) ->
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
      target

  class exports.WorldState extends exports.State
    init: ->
      @timestamp = +new Date()
      @players = []
      @enemies = []


)(if exports? then exports else window["state"] = {})
