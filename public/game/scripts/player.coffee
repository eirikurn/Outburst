class Player extends THREE.Object3D
  constructor: (state, @camera) ->
    super()
    loader = new THREE.JSONLoader()
    loader.load
      model: "models/figure.js"
      callback: (geo) => 
        @makeModel(geo)
    @createAimer()

    @camera.target = this
    @lastPos = x: state.x, y: state.y
    @addState(state)

  addState: (state) ->
    moved = state.x != @lastPos.x or state.y != state.y
    @position.x = state.x
    @position.y = state.y
    @camera.position.x = state.x
    @camera.position.y = state.y - 500
    @aimerContainer.rotation.z = state.aimDirection

    if @model
      @model.rotation.y = state.walkDirection
      @model.isPaused = not moved

    @lastPos.x = state.x
    @lastPos.y = state.y

  applyInput: (input) ->
    # @addState @state.applyInput(input)

  onFrame: (delta) ->
    @model.updateAnimation (delta)

  makeModel: (geometry) ->
    geometry.materials[0][0].shading = THREE.FlatShading
    geometry.materials[0][0].morphTargets = true
    @model = new AnimatedMesh geometry, [ new THREE.MeshFaceMaterial() ],
      walk:
        firstKeyframeIndex: 0
        duration: 850
        keyframes: 27
    @model.scale.x = @model.scale.y = @model.scale.z = 20
    @model.rotation.x = Math.PI/2
    @model.position.z = 100
    @addChild @model
    @model.playAnimation "walk"
    
  createAimer: () ->
    @aimer = new THREE.Mesh(new THREE.CylinderGeometry(10, 0, 5, 50, 0, 0), new THREE.MeshLambertMaterial(color: 0xFF0000))
    @aimer.rotation.x = Math.PI / 2
    @aimer.rotation.y = Math.PI / 2
    @aimer.position.x = -100
    @aimer.position.y = 10
    @aimerContainer = new THREE.Object3D()
    @aimerContainer.addChild @aimer
    @addChild @aimerContainer
  
# export
@Player = Player
