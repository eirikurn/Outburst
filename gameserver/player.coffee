
class Player
  constructor: (@socket, @state) ->
    @inputs = []
    @lastUpdate = +new Date / 1000

  toJSON: ->
    {}

module.exports = Player

