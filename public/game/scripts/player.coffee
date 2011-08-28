class PlayerUnit extends THREE.Object3D
  constructor: (state) ->
    super()
    Loader.getModel "models/svenn.js", @makeModel
    @createAimer()
    @addState(state)

  addState: (state) ->
    @position.x = state.x
    @position.y = state.y
    @aimerContainer.rotation.z = state.aimDirection
    if state.shots
      for shot in state.shots
        game.addShot @, shot

    if @model
      @model.rotation.y = state.walkDirection + Math.PI / 2
      @model.isPaused = not state.isMoving

  onFrame: (delta) ->
    @model.updateAnimation (delta) if @model

  makeModel: (geometry) =>
    material = new THREE.MeshBasicMaterial( { map: geometry.materials[0][0].map, morphTargets: true });
    @model = new AnimatedMesh geometry, material,
      walk:
        firstKeyframeIndex: 0
        duration: 1500
        keyframes: 24
    @model.scale.x = @model.scale.y = @model.scale.z = 10
    @model.rotation.x = Math.PI/2
    @model.position.z = 100
    @model.playAnimation "walk"
    @model.isPaused = yes
    @addChild @model

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
