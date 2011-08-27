class Player extends THREE.Object3D
  constructor: ->
    super()
    loader = new THREE.JSONLoader()
    loader.load
      model: "models/figure.js"
      callback: (geo) => 
        @makeModel(geo)
    @createAimer()
  
  
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
  
  updatePlayer: (delta) -> 
    @updatePosition(delta)
    @updateRotation(delta)
    @updateAimer(delta)
    @updateAnimation(delta)
    
  createAimer: () ->
    @aimer = new THREE.Mesh(new THREE.CylinderGeometry(10, 0, 5, 50, 0, 0), new THREE.MeshLambertMaterial(color: 0xFF0000))
    @aimer.rotation.x = Math.PI / 2
    @aimer.rotation.y = Math.PI / 2
    @aimer.position.x = -100
    @aimer.position.z = 10
    @aimerContainer = new THREE.Object3D()
    @aimerContainer.addChild @aimer
    @addChild @aimerContainer
    
  updateAimer: (delta) ->
    @aimerContainer.rotation.z = Math.atan2 @position.y-input.mouse.y, @position.x-input.mouse.x 
  
  updatePosition: (delta) ->
    @lastPos = 
      x: @position.x
      y: @position.y
      
    @position.y += delta * 200 if input.up
    @position.y -= delta * 200 if input.down
    @position.x -= delta * 200 if input.left
    @position.x += delta * 200 if input.right
  
  updateRotation: (delta) ->
    if @lastPos and (input.up or input.down or input.left or input.right)
      @model.rotation.y = Math.atan2 @position.x - @lastPos.x, @lastPos.y - @position.y
      
  updateAnimation: (delta) ->
    if @model
      @model.updateAnimation (delta)
      @model.isPaused = not (input.up or input.down or input.left or input.right)
  
  
  
# export
@Player = Player