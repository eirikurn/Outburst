{EnemyState} = require './shared/states.coffee'
constants = require './shared/constants.coffee'

class Enemy
  constructor: (data) ->
    @state = new EnemyState(data)
    @hp = data.hp
    @waypointDelta = new THREE.Vector2().set(data.waypointDelta...)
    @currentWaypoint = 0
    @velocity = new THREE.Vector2()
    @distance = 0
    @direction = 0
    @findNextWaypoint()

  findNextWaypoint: ->
    @target = constants.MAP.waypoints[@currentWaypoint++]
    if not @target
      @velocity = new THREE.Vector2()
      return

    @target = new THREE.Vector2().set(@target...)
    @target.addSelf(@waypointDelta)
    toTarget = new THREE.Vector2().sub(@target, new THREE.Vector2(@state.x, @state.y))
    @distance = toTarget.length()
    @velocity = toTarget.setLength(constants.ENEMY_SPEED * constants.TIME_PER_TICK)
    @direction = Math.atan2(@velocity.y, @velocity.x)

    @target

  onTick: (world) ->
    return null if not @target

    newState = @state.clone()
    newState.x += @velocity.x
    newState.y += @velocity.y
    newState.direction = @direction

    @distance -= constants.ENEMY_SPEED * constants.TIME_PER_TICK
    if @distance < 0 then @findNextWaypoint()

    return @state = newState

module.exports = Enemy
