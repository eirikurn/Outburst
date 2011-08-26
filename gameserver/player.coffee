
class Player
  constructor: (@socket) ->
    @inputs = []

  toJSON: ->
    {}

module.exports = Player

