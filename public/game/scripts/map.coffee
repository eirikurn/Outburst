class Map extends THREE.Object3D
  constructor: ->
    super()
    
    texture = THREE.ImageUtils.loadTexture "maps/grass-texture.jpg"
    texture.wrapT = texture.wrapS = THREE.RepeatWrapping
    plane = new THREE.PlaneGeometry 10000, 10000, 1, 1
    plane.faceVertexUvs[0][0] = [
      new THREE.UV  0, 0
      new THREE.UV  0, 10
      new THREE.UV 10, 10
      new THREE.UV 10, 0
    ]
    @map = new THREE.Mesh(
      plane,
      new THREE.MeshBasicMaterial(map: texture)
    )
    @addChild @map

# export
@Map = Map
