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
  exports.PLAYER_SPEED = 200

)(if exports? then exports else window["constants"] = {})
