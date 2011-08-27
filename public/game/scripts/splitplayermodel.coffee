class SplitPlayerModel extends THREE.Object3D
  constructor: ->
    super()
    Loader.getModel "models/legs.js", @makeLegs
    Loader.getModel "models/tophalf.js", @makeTophalf
    
  
  makeLegs: (geometry) =>
    material = new THREE.MeshBasicMaterial( { map: geometry.materials[0][0].map, morphTargets: true });
    @legs = new AnimatedMesh geometry, material,
      stopped:
        firstKeyFrameIndex: 0
        duration: 0
        keyframes: 1
      walk:
        firstKeyframeIndex: 1
        duration: 600
        keyframes: 24
    @legs.scale.x = @legs.scale.y = @legs.scale.z = 10
    @legs.rotation.x = Math.PI / 2
    @legs.rotation.y = Math.PI / 2
    @legs.position.z = 130
    @legs.position.x = 13;
    @legs.playAnimation "stopped"
    @legs.isPaused = yes
    @legsContainer = new THREE.Object3D()
    
    @legsContainer.addChild @legs
    @addChild @legsContainer 
  
  makeTophalf: (geometry) =>
    material = new THREE.MeshBasicMaterial( { map: geometry.materials[0][0].map });
    @topHalf = new THREE.Mesh geometry, material
    @topHalf.position.z = 130
    @topHalf.rotation.x = Math.PI / 2
    @topHalf.rotation.y = Math.PI / 2
    @topHalf.position.x = 13;
    @topHalf.scale.x = @topHalf.scale.y = @topHalf.scale.z = 10
    @topHalfContainer = new THREE.Object3D()
    @topHalfContainer.addChild @topHalf
    @addChild @topHalfContainer
  
  onFrame: (delta) ->
    if not @legs or not @topHalf then return
    @legs.updateAnimation (delta)
    
  onStateUpdate: (rotation, aimRotation, isMoving) ->
    if not @legs or not @topHalf then return
    @legsContainer.rotation.z = rotation
    @topHalfContainer.rotation.z = aimRotation
    if not isMoving and not @legs.isPaused
      @legs.playAnimation "stopped"
      @legs.isPaused = yes
    if isMoving and @legs.isPaused
      @legs.playAnimation "walk"

# export
@SplitPlayerModel = SplitPlayerModel