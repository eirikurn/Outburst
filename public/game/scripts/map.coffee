class Map extends THREE.Object3D
  constructor: ->
    super()
    
    texture = THREE.ImageUtils.loadTexture "images/grass.jpg"
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
    
    # Draw roads
    @roadTexture = THREE.ImageUtils.loadTexture "images/road.png"
    @roadTexture.wrapT = @roadTexture.wrapS = THREE.RepeatWrapping
    @cornerTexture = THREE.ImageUtils.loadTexture "images/road-corner.png"
    @waypointSize = constants.MAP.waypointSize
    
    # Add roads
    previous = constants.MAP.enemySpawn
    for waypoint in constants.MAP.waypoints
      @addRoad previous, waypoint
      previous = waypoint
      
    # Add corners
    @addCorner constants.MAP.enemySpawn
    for waypoint in constants.MAP.waypoints
      @addCorner waypoint
      
    
  addCorner: (pos) ->
    plane = new THREE.PlaneGeometry(@waypointSize * 2, @waypointSize * 2)
    material = new THREE.MeshBasicMaterial(map: @cornerTexture, transparent: true)
    mesh = new THREE.Mesh plane, material
    mesh.position.x = pos[0]
    mesh.position.y = pos[1]
    mesh.position.z = 15
    @addChild mesh
    
  addRoad: (from, to) ->
    
    z = if @odd = !@odd then 10 else 5
    road = new Road @roadTexture, from, to, z
    @addChild road
    
class Road extends THREE.Object3D
  constructor: (texture, from, to, z) ->
    super()
    
    vector = new THREE.Vector2().set(to...).subSelf(new THREE.Vector2().set(from...))
    
    @position.x = from[0]
    @position.y = from[1]
    @position.z = z
    @rotation.z = Math.atan2 vector.y, vector.x
    
    width = vector.length()
    height = constants.MAP.waypointSize
    
    plane = new THREE.PlaneGeometry(width, height * 2)
    plane.faceVertexUvs[0][0] = [
      new THREE.UV  0, 0
      new THREE.UV  0, height/512
      new THREE.UV width/512, height/512
      new THREE.UV width/512, 0
    ]
    material = new THREE.MeshBasicMaterial(map: texture, transparent: true)
    mesh = new THREE.Mesh plane, material
    
    mesh.position.x = vector.length() / 2 
    @addChild mesh

# export
@Map = Map
