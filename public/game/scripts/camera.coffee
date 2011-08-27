class Camera extends THREE.Camera
  constructor: (width, height) ->
    super 45, width / height, 1, 10000
    @position.z = 1000

# export
@Camera = Camera