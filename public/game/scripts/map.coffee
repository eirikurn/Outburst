class Map extends THREE.Object3D
  constructor: ->
    super()
    @.position.x = -100
    @.position.y = -100
    
    texture = THREE.ImageUtils.loadTexture "maps/grass-texture.jpg"
    texture.wrapT = texture.wrapS = THREE.RepeatWrapping
    plane = new THREE.PlaneGeometry 2048, 2048, 1, 1
    plane.faceVertexUvs[0][0] = [
      new THREE.UV 0, 0
      new THREE.UV 0, 2
      new THREE.UV 2, 2
      new THREE.UV 2, 0
    ]
    @map = new THREE.Mesh(
      plane,
      new THREE.MeshBasicMaterial(map: texture)
    )
    @addChild @map

# export
@Map = Map