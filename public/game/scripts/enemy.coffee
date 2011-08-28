class Enemy extends THREE.Object3D
  constructor: (state) ->
    super()
    @robotContainer = new THREE.Object3D()
    @robotContainer.scale.x = @robotContainer.scale.y = @robotContainer.scale.z = 60
    @robotContainer.position.z = 1
    @robotContainer.rotation.x = Math.PI / 2
    @robotContainer.rotation.y = Math.PI / 2
    @addChild @robotContainer
    @bladeContainer = new THREE.Object3D()
    @robotContainer.addChild @bladeContainer
    @bladeContainer.position.z = 2.25
    @bladeContainer.position.y = 1.45
    
    Loader.getModel "models/robotblade.js", @makeBlade
    Loader.getModel "models/robotbody.js", @makeModel
    Loader.getModel "models/robottracks.js", @makeModel
    @addState state
    
  addState: (state) ->
    @position.x = state.x
    @position.y = state.y
    @rotation.z = state.direction
  
  makeModel: (geometry) =>
    material = new THREE.MeshBasicMaterial( { map: geometry.materials[0][0].map })
    part = new THREE.Mesh geometry, material
    @robotContainer.addChild part
   
  makeBlade: (geometry) =>
    material = new THREE.MeshBasicMaterial( { map: geometry.materials[0][0].map })
    @blade = new THREE.Mesh geometry, material
    @blade.position.y = -1.5
    @blade.position.z = -2.3
    @bladeContainer.addChild @blade
  
  onFrame: (delta) ->
    if not @blade then return
    @bladeContainer.rotation.x += delta*30


# export
@Enemy = Enemy