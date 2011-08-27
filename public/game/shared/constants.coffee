((exports)->

  # Game loop and network constants
  exports.TICKS_PER_SECOND = 60
  exports.TIME_PER_TICK = 1 / exports.TICKS_PER_SECOND

  exports.UPDATES_PER_SECOND = 30
  exports.TIME_BETWEEN_UPDATES = 1 / exports.UPDATES_PER_SECOND

  exports.INPUTS_PER_SECOND = 30
  exports.TIME_BETWEEN_INPUTS = 1 / exports.INPUTS_PER_SECOND

  exports.BUFFER_INPUTS = 0.05
  exports.ROLLBACK_TIME = 1

  # Gameplay constants
  exports.PLAYER_SPEED = 200

)(if exports? then exports else window["constants"] = {})
