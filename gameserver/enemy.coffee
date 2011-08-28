{EnemyState} = require './shared/states'
constants = require '/shared/constants'

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
    @velocity = [@target.x - @state.x, @target[1] - @state.y]
    @target

  update: (world)
    newState = @state.clone()
    newState.x += @velocity[0]
    newState.y += @velocity[1]
    return @state = newState

module.exports = Enemy
