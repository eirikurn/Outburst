class Player
  constructor: (@scene) ->
    # TEST OBJECT
    @model = new THREE.Mesh(
      new THREE.SphereGeometry(50, 16, 16),
      new THREE.MeshLambertMaterial(color: 0xCC0000)
    )
    @scene.addChild @model
  
  update: (delta) ->
    @model.position.y += delta * 200 if input.up
    @model.position.y -= delta * 200 if input.down
    @model.position.x -= delta * 200 if input.left
    @model.position.x += delta * 200 if input.right
  
# export
@Player = Player