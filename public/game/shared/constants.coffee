((exports)->

  # Game loop and network constants
  exports.TICKS_PER_SECOND = 50
  exports.TIME_PER_TICK = 1 / exports.TICKS_PER_SECOND

  exports.TIME_BETWEEN_UPDATES = 1 / 25
  exports.TIME_BETWEEN_INPUTS = 1 / 25

  exports.BUFFER_INPUTS = 0.05
  exports.ROLLBACK_TIME = 1

  exports.INTERPOLATE_FRAMES = 2

  # Shared gameplay constants
  exports.PLAYER_SPEED = 600
  exports.SHOT_DISTANCE = 2000

  exports.WEAPONS =
    pistol:
      damage: 50
      recoilTime: .5
      ammo: 12
      reloadTime: 1.5
      spread: 3 * (Math.PI / 180)
    machinegun:
      damage: 20
      recoilTime: .1
      ammo: 30
      reloadTime: 1.5
      automatic: yes
      spreadPerShot: 2 * (Math.PI / 180)
      spreadMax: 25 * (Math.PI / 180)
      spreadTime: 1.5
    shotgun:
      damage: 200
      recoilTime: .75
      ammo: 7
      reloadTime: 2.5
      shards: 8
      spread: 35 * (Math.PI / 180)

  # Client constants
  exports.DISPLAY_STATS = false

  # Server constants
  exports.FIRST_WAVE = 4 # 12?
  exports.WAVE_INTERVAL = 25 # 30?
  exports.SPAWN_RATE = 0.4
  exports.START_LIVES = 6

  exports.ENEMIES_PER_WAVE = 15
  exports.ENEMY_SPEED = 300
  exports.ENEMY_BASE_HP = 40
  exports.ENEMY_HP_PER_WAVE = 30
  
  exports.SHEEP_HEALTH = 100

  # MAP
  exports.MAP_SIZE = [10000, 10000]
  exports.MAP =
    base: [0, -1500]           #bottom center
    playerSpawn: [-1500, 1500] #[500, -1500]  #at base entrance
    enemySpawn: [-1500, 1500]  #top left
    waypointSize: 500
    waypoints: [
      [-1500, -1500] # top left
      [0, 0]         # center
      [1500, 0]      # right
      [1500, -1500]  # bottom right
      [0, -1500]     # base
    ]

)(if exports? then exports else window["constants"] = {})
