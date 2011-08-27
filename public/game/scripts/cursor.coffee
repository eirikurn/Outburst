class Cursor
  constructor: (scene) ->
    @model = new THREE.Mesh(
      new THREE.SphereGeometry(30, 8, 8),
      new THREE.MeshLambertMaterial(color: 0x00FFFF)
    )
    scene.addChild @model
  
  update: (delta) ->
    @model.position.x = input.mouse.x
    @model.position.y = input.mouse.y


# export
@Cursor = Cursor