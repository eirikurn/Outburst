requestAnimFrame = (->
  window.requestAnimationFrame || 
  window.webkitRequestAnimationFrame || 
  window.mozRequestAnimationFrame    || 
  window.oRequestAnimationFrame      || 
  window.msRequestAnimationFrame     || 
  (callback, element) ->
    window.setTimeout(callback, 1000 / 60)
)()

socket = io.connect()
socket.on 'welcome', (data) ->
  console.log data
  
class Camera extends THREE.Camera
  constructor: (width, height) ->
    super 45, width / height, 1, 10000
    @position.z = 1000
    
class Input
  constructor: ->
    document.body.addEventListener 'keyup', (ev) => @keyup(ev)
    document.body.addEventListener 'keydown', (ev) => @keydown(ev)
  
  keys:
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    65: 'left' # A
    87: 'up' # W
    68: 'right' # D
    83: 'down' # S
    
  keydown: (event) ->
    @[@keys[event.keyCode]] = true
  
  keyup: (event) ->
    @[@keys[event.keyCode]] = false
    
class World
  constructor: (width, height) ->
    @camera = new Camera(width, height)
    @scene = new THREE.Scene()
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(width, height)
    @container = document.getElementById 'container'
    @container.style.width = width + 'px'
    @container.style.height = height + 'px'
    @container.appendChild(@renderer.domElement)
    
    # TEST OBJECT
    @test = new THREE.Mesh(
      new THREE.SphereGeometry(50, 16, 16),
      new THREE.MeshLambertMaterial(color: 0xCC0000)
    )
    @scene.addChild @test 
  
  render: ->
    @renderer.render(@scene, @camera)
  
  update: (delta) ->
    @test.position.y += delta * 200 if input.up
    @test.position.y -= delta * 200 if input.down
    @test.position.x -= delta * 200 if input.left
    @test.position.x += delta * 200 if input.right
    
last = +new Date
animloop = ->
  now = +new Date
  delta = (now - last) / 1000.0
  last = now
  requestAnimFrame(animloop, world.container)
  
  world.update(delta)
  world.render()
    
document.addEventListener 'DOMContentLoaded', ->
  window.input = new Input()
  window.world = new World window.innerWidth - 10, window.innerHeight - 10
  animloop()
  
trace = (message) ->
  console?.log message
