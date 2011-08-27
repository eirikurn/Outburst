((exports)->

  # Game loop and network constants
  exports.TICKS_PER_SECOND = 50
  exports.TIME_PER_TICK = 1 / exports.TICKS_PER_SECOND

  exports.TIME_BETWEEN_UPDATES = 1 / 25
  exports.TIME_BETWEEN_INPUTS = 1 / 25

  exports.BUFFER_INPUTS = 0.05
  exports.ROLLBACK_TIME = 1

  exports.INTERPOLATE_FRAMES = 2

  # Gameplay constants
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

)(if exports? then exports else window["constants"] = {})
