class Sheep extends THREE.Object3D
  constructor: (state) ->
    super()
    Loader.getModel "models/sheep.js", @makeModel
    @addStage state
  
  addState: (state) ->
    @position.x = state.x
    @position.y = state.y
    @rotation.z = state.direction
    
  makeModel: (geometry) =>
    material = new THREE.MeshBasicMaterial( )
    @sheep = new THREE.Mesh geometry, material
    @sheep.scale.x = @sheep.scale.y = @sheep.scale.z = 40
    @sheep.position.z = 35
    @sheep.rotation.x = Math.PI / 2
    @sheep.rotation.y = Math.PI / 2
    @addChild @sheep
  

# export
@Sheep = Sheep