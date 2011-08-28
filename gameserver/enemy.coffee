{EnemyState} = require './shared/states.coffee'
constants = require './shared/constants.coffee'

class Enemy
  constructor: (data) ->
    @state = new EnemyState(data)
    @hp = data.hp
    @waypointDelta = data.waypointDelta
    @currentWaypoint = 0
    @velocity = [0, 0]
    @findNextWaypoint()

  findNextWaypoint: ->
    @target = constants.MAP.waypoints[@currentWaypoint++]
    return unless @target
    @target[0] += @waypointDelta[0]
    @target[1] += @waypointDelta[1]
    @velocity = [@target[0] - @state.x, @target[1] - @state.y]
    @target

  onTick: (world) ->
    newState = @state.clone()
    newState.x += @velocity[0] * constants.TIME_PER_TICK * 0.1
    newState.y += @velocity[1] * constants.TIME_PER_TICK * 0.1
    return @state = newState

module.exports = Enemy
