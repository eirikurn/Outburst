{SheepState} = require './shared/states.coffee'
constants = require './shared/constants.coffee'

class Sheep
  constructor: (data) ->
    @state = new SheepState(data)
    @hp = data.hp

  onTick: (world) ->
    newState = @state.clone()
    # Let them shiver
    newState.direction += Math.random() * 0.1 - 0.05 
    return @state = newState

module.exports = Sheep