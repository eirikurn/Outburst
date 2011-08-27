
class Player
  constructor: (@socket, @state) ->
    @inputs = []

  toJSON: ->
    {}

module.exports = Player

