class Player extends THREE.Object3D
  constructor: ->
    super()
    loader = new THREE.JSONLoader()
    loader.load
      model: "models/figure.js"
      callback: (geo) => 
        @makeModel(geo)
  
  
  makeModel: (geometry) ->
    geometry.materials[0][0].shading = THREE.FlatShading
    geometry.materials[0][0].morphTargets = true
    @model = new AnimatedMesh geometry, [ new THREE.MeshFaceMaterial() ],
      walk:
        firstKeyframeIndex: 0
        duration: 1500
        keyframes: 27
    @model.scale.x = @model.scale.y = @model.scale.z = 20
    @model.rotation.x = 90
    @addChild @model
    console.log @children.length
    @model.playAnimation "walk"
  
  updatePlayer: (delta) -> 
    if @model
      moved = input.up or input.down or input.left or input.right
      
      @model.position.y += delta * 200 if input.up
      @model.position.y -= delta * 200 if input.down
      @model.position.x -= delta * 200 if input.left
      @model.position.x += delta * 200 if input.right
      @model.updateAnimation (delta)
      @model.isPaused = not moved
      
      if @lastPos and moved
        @model.rotation.y = Math.atan2 @model.position.x - @lastPos.x, @lastPos.y - @model.position.y
        
      @lastPos = 
        x: @model.position.x
        y: @model.position.y
  
  
  
# export
@Player = Player