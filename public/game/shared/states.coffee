((exports)->
  constants = require './constants.coffee'
  random = require './random'

  class exports.State
    constructor: ->
      if arguments[0] != false
        @init.apply this, arguments

    init: ->

  class exports.UnitState extends exports.State
    init: (data = {}) ->
      for k in @constructor.fields when data[k]?
        @[k] = data[k]

    clone: (target = new @constructor()) ->
      for k in @constructor.fields
        target[k] = @[k]
      target

    @fields = ['x', 'y', 'id']

  class exports.PlayerState extends exports.UnitState
    init: ->
      @walkDirection = 0
      @aimDirection = 0
      @isMoving = no
      @weapon = "pistol"
      @recoil = 0
      @reload = 0
      @spread = 0
      @ammo = constants.WEAPONS[@weapon].ammo
      @shots = []
      super

    applyInput: (input, target = @) ->
      velocity = constants.PLAYER_SPEED * constants.TIME_PER_TICK
      deltaX = 0; deltaY = 0
      deltaX += velocity if input.right
      deltaX -= velocity if input.left
      deltaY += velocity if input.up
      deltaY -= velocity if input.down

      if deltaX and deltaY
        deltaX *= 0.707106781 # Math.sin(45°)
        deltaY *= 0.707106781 # Math.sin(45°)

      # Update position
      target.x = @x + deltaX
      target.y = @y + deltaY

      # Update directions
      target.walkDirection =
        if deltaX or deltaY
          Math.atan2(deltaY, deltaX)
        else
          @walkDirection or 0
      target.aimDirection = Math.atan2(input.mouseY - target.y, input.mouseX - target.x)

      # Update animations
      target.isMoving = input.right or input.left or input.up or input.down

      # Update shots/weapons
      oldSpread = @spread
      oldReload = @reload
      activeWeapon = constants.WEAPONS[@weapon]
      target.seed = @seed
      target.weapon = @weapon
      target.ammo = @ammo
      target.shots = []
      target.recoil = Math.max @recoil - constants.TIME_PER_TICK, 0
      target.reload = Math.max @reload - constants.TIME_PER_TICK, 0
      if not target.reload and oldReload
        target.ammo = activeWeapon.ammo
      if activeWeapon.automatic and @spread
        deltaSpread = activeWeapon.spreadMax * activeWeapon.spreadTime / constants.TIME_PER_TICK
        target.spread = Math.max @spread - deltaSpread, 0
        target.spread

      if input.mouseDown and not target.recoil and target.ammo
        target.recoil = activeWeapon.recoilTime
        target.ammo--
        target.reload = activeWeapon.reloadTime if not target.ammo

        # Create shot
        rnd = random.generator(@seed)
        spread = activeWeapon.spread
        createShot = -> 
          direction = target.aimDirection + rnd() * activeWeapon.spread
          console.log direction
          direction
        if activeWeapon.shards
          target.shots.push createShot() for i in [0...activeWeapon.shards]
        else if activeWeapon.automatic
          spread = target.spread = Math.min(activeWeapon.spread + (oldSpread or 0), activeWeapon.maxSpread)
          target.shots.push createShot()
        else
          target.shots.push createShot()

      target

    @fields = ['x', 'y', 'id', 'walkDirection', 'aimDirection', 'isMoving',
      'seed', 'weapon', 'recoil', 'reload', 'spread', 'ammo', 'shots']

  class exports.WorldState extends exports.State
    init: (data = {}) ->
      @timestamp = data.timestamp
      @players = (new exports.PlayerState(p) for p in data.players or [])

)(if exports? then exports else window["states"] = {})
