class Enemy extends THREE.Object3D
  constructor: (state) ->
    super()
    Loader.getModel "models/robot.js", @makeModel
    @addState(state)
    
  addState: (state) ->
    @position.x = state.x
    @position.y = state.y
    @rotation.z = state.direction
  
  makeModel: (geometry) =>
    material = new THREE.MeshBasicMaterial( { map: geometry.materials[0][0].map, morphTargets: true });
    @robot = new AnimatedMesh geometry, material,
      walk:
        firstKeyframeIndex: 0
        duration: 5000
        keyframes: 12
        
    @robot.overdraw = true;
    @robot.updateMatrix();
    @robot.scale.x = @robot.scale.y = @robot.scale.z = 40
    @robot.position.z = 1
    @robot.rotation.x = Math.PI / 2
    @robot.rotation.y = Math.PI / 2
    @robot.playAnimation "walk"
    
    @addChild @robot


# export
@Enemy = Enemy