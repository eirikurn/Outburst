{EnemyState} = require './shared/states'

class Enemy
  constructor: (data) ->
    @state = new EnemyState(data)


module.exports = Enemy
