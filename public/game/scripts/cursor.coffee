class Cursor extends THREE.Object3D
  constructor: ->
    super
    @model = new THREE.Mesh(
      new THREE.SphereGeometry(10, 8, 8),
      new THREE.MeshLambertMaterial(color: 0x00FFFF)
    )
    @addChild @model
  
  onFrame: (delta) ->
    @model.position.x = input.mouse.x
    @model.position.y = input.mouse.y


# export
@Cursor = Cursor