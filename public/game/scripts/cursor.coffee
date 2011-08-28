class Cursor extends THREE.Object3D
  constructor: (camera) ->
    super()
    @aimer = new THREE.Mesh(
      new THREE.SphereGeometry(10, 8, 8),
      new THREE.MeshLambertMaterial(color: 0x00FFFF)
    )
    @addChild @aimer
    
    @spread = new THREE.Mesh(
      new THREE.SphereGeometry(10, 8, 8),
      new THREE.MeshLambertMaterial(color: 0x000000, opacity: 0.3, transparent: true)
    )
    @aimer.position.z = @spread.position.z = 200
    @spread.scale.z = 0.8
    @addChild @spread
  
  onFrame: (camera, state) ->
    @spread.position.x = @aimer.position.x = input.mouse.x
    @spread.position.y = @aimer.position.y = input.mouse.y
    if state and state.spread > 0
      val = state.spread * 50
      @spread.scale.x = val 
      @spread.scale.y = val

# export
@Cursor = Cursor