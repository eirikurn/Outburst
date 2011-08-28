class PlayerUnit extends THREE.Object3D
  constructor: (state) ->
    super()
    @splitModel = new SplitPlayerModel()
    @addChild @splitModel
    @createAimer()
    @addState(state)

  addState: (state) ->
    @position.x = state.x
    @position.y = state.y
    @aimerContainer.rotation.z = state.aimDirection
    if state.shots
      for shot in state.shots
        game.addShot @, shot

    @splitModel.onStateUpdate state.walkDirection, state.aimDirection, state.isMoving

  onFrame: (delta) ->
    @splitModel.onFrame delta


  createAimer: () ->
    @aimer = new THREE.Mesh(new THREE.CylinderGeometry(10, 0, 5, 50, 0, 0), new THREE.MeshLambertMaterial(color: 0xFF0000))
    @aimer.rotation.x = Math.PI / 2
    @aimer.rotation.y = -Math.PI / 2
    @aimer.position.x = 100
    @aimer.position.z = 10
    @aimerContainer = new THREE.Object3D()
    @aimerContainer.addChild @aimer
    @addChild @aimerContainer

class Player extends PlayerUnit
  constructor: (state, @camera) ->
    super(state)
    @camera.target = this
    @state = state

  addState: (state) ->
    # Ignore server state for now. Validate client predictions later

  applyInput: (input) ->
    @state.applyInput input
    Player.__super__.addState.call this, @state
    @camera.position.x = @state.x
    @camera.position.y = @state.y - 800

# export
@PlayerUnit = PlayerUnit
@Player = Player
