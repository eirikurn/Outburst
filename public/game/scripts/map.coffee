class Map extends THREE.Object3D
  constructor: ->
    super()
    
    texture = THREE.ImageUtils.loadTexture "maps/grass-texture.jpg"
    texture.wrapT = texture.wrapS = THREE.RepeatWrapping
    mapW = constants.MAP_SIZE[0]
    mapH = constants.MAP_SIZE[1]
    plane = new THREE.PlaneGeometry mapW, mapH, 1, 1
    plane.faceVertexUvs[0][0] = [
      new THREE.UV  0, 0
      new THREE.UV  0, mapH/1000
      new THREE.UV mapW/1000, mapH/1000
      new THREE.UV mapW/1000, 0
    ]
    @map = new THREE.Mesh(
      plane,
      new THREE.MeshBasicMaterial(map: texture)
    )
    @addChild @map

# export
@Map = Map
