((exports)->
  constants = require './constants.coffee'
  random = require './random'

  class exports.State
    constructor: ->
      if arguments[0] != false
        @init.apply this, arguments

    init: (data = {}) ->
      for k in @constructor.fields when data[k]?
        @[k] = data[k]

    clone: (target = new @constructor()) ->
      for k in @constructor.fields
        target[k] = @[k]
      target

    @fields = []

  class exports.EnemyState extends exports.State
    @fields = ['x', 'y', 'id', 'hp', 'direction']
    
  class exports.SheepState extends exports.State
    @fields = ['x', 'y', 'id', 'hp', 'direction']

  class exports.PlayerState extends exports.State
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
      @nick = ""
      super

    applyInput: (input, world, target = @) ->
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
      
      target.nick = @nick

      # Update shots/weapons
      oldWeapon = @weapon
      oldSpread = @spread
      oldReload = @reload

      target.weapon =
        if input.weapon1      then "pistol"
        else if input.weapon2 then "machinegun"
        else if input.weapon3 then "shotgun"
        else                       @weapon
      activeWeapon = constants.WEAPONS[target.weapon]

      if target.weapon != oldWeapon
        target.ammo = activeWeapon.ammo
      else
        target.ammo = @ammo

      target.seed = @seed
      target.shots = []
      target.recoil = Math.max @recoil - constants.TIME_PER_TICK, 0
      target.reload = Math.max @reload - constants.TIME_PER_TICK, 0
      if not target.reload and oldReload
        target.ammo = activeWeapon.ammo
      if activeWeapon.automatic and @spread
        deltaSpread = activeWeapon.spreadMax / (activeWeapon.spreadTime / constants.TIME_PER_TICK)
        target.spread = Math.max @spread - deltaSpread, 0
        target.spread

      if input.mouseDown and not target.recoil and target.ammo
        target.recoil = activeWeapon.recoilTime
        target.ammo--
        target.reload = activeWeapon.reloadTime if not target.ammo

        # Create shot
        rnd = random.generator(@seed)
        spread = activeWeapon.spread
        if activeWeapon.shards
          target.shots.push @createShot(world, target, spread, rnd) for i in [0...activeWeapon.shards]
        else if activeWeapon.automatic
          spread = target.spread = Math.min(activeWeapon.spreadPerShot + (oldSpread or 0), activeWeapon.spreadMax)
          target.shots.push @createShot(world, target, spread, rnd)
        else
          target.shots.push @createShot(world, target, spread, rnd)

      target
      
    vecDot: (vec1, vec2) ->
      vec1.x * vec2.x + vec1.y * vec2.y;
    
    createShot: (world, target, spread, rnd) ->
      direction = target.aimDirection + (rnd() * spread) - (spread/2)
      start =
        x: target.x + constants.SHOT_OFFSET_FROM_PLAYER_CENTER * Math.cos direction
        y: target.y + constants.SHOT_OFFSET_FROM_PLAYER_CENTER * Math.sin direction

      #distance = @calculateIntersection start, direction, world
      distance = @shotHitsObject { x: 500, y: 600 }, 100, start, direction
      distance = constants.SHOT_DISTANCE if distance == -1
      #targetLocation, targetRadius, shotStart, direction
        
      returnData = 
        direction: direction
        length: distance
        x: start.x
        y: start.y
    
    calculateIntersection: (shotStart, direction, world) ->
      minLength = constants.SHOT_DISTANCE
      hitEnemy = null
      
      for enemy in world.enemies
        hitLength = @shotHitsObject { x: enemy.x, y: enemy.y }, constants.ENEMY_RADIUS, shotStart, direction
        if hitLength =! -1
          if hitLength < minLength
            minLength = hitLength
            hitEnemy = enemy
       
        if hitEnemy
          hitEnemt.hp -= 1 # or some constant
        
        return minLength
        
      
    shotHitsObject: (targetLocation, targetRadius, shotStart, direction) ->
      end = 
        x: shotStart.x + constants.SHOT_DISTANCE * Math.cos direction
        y: shotStart.y + constants.SHOT_DISTANCE * Math.sin direction
      
      distance = constants.SHOT_DISTANCE
      
      # d = L - E ; // Direction vector of ray, from start to end
      d =
        x: end.x - shotStart.x
        y: end.y - shotStart.y
      # f = E - C ; // Vector from center sphere to ray start
      f =
        x: shotStart.x - targetLocation.x
        y: shotStart.y - targetLocation.x
      
      a = @vecDot d, d
      b = 2 * @vecDot f, d
      c = @vecDot(f, f) - targetRadius*targetRadius
      discriminant = b * b - 4 * a * c
      
      if discriminant < 0
        return -1
      else
        discriminant = Math.sqrt discriminant
        t1 = (-b + discriminant) / (2 * a)
        t2 = (-b - discriminant) / (2 * a)
        
        if t1 >= 0 and t1 <= 1 or t2 >= 0 and t2 <= 1
          sca = 0
          if t1 >= 0 and t1 <= 1 or t2 >= 0 and t2 <= 1
            sca = Math.min t1, t2
          else if t1 >= 0 and t1 <= 1
            sca = t1
          else
            sca = t2
            
          console.log "COLLISION!", sca
          distance = constants.SHOT_DISTANCE * sca
          return distance
        else
          return -1
      

    @fields = ['x', 'y', 'id', 'walkDirection', 'aimDirection', 'isMoving',
      'seed', 'weapon', 'recoil', 'reload', 'spread', 'ammo', 'shots', 'nick']

  class exports.WorldState extends exports.State
    init: (data = {}) ->
      data.wave or= 0
      data.lives or= 0
      data.tick or= 0
      @players = (new exports.PlayerState(p) for p in data.players or [])
      @enemies = (new exports.EnemyState(e) for e in data.enemies or [])
      @sheeps = (new exports.SheepState(s) for s in data.sheeps or [])
      super

    @fields = ['lives', 'wave', 'tick']

)(if exports? then exports else window["states"] = {})
