class Camera extends THREE.Camera
  constructor: (width, height) ->
    super 45, 16 / 9, 100, 5000
    @position.z = 2000
  
  onFrame: ->
    @position.z = input.mouse.scroll 

# export
@Camera = Camera
