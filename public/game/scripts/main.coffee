requestAnimFrame = ->
  window.requestAnimationFrame || 
  window.webkitRequestAnimationFrame || 
  window.mozRequestAnimationFrame    || 
  window.oRequestAnimationFrame      || 
  window.msRequestAnimationFrame     || 
  (callback, element) ->
    window.setTimeout(callback, 1000 / 60)


socket = io.connect()
socket.on 'welcome', (data) ->
  console.log data
  
class Camera extends THREE.Camera
  constructor: (width, height) ->
    super 45, width / height, 1, 10000
    @position.z = 1000
    
class World
  constructor: (width, height) ->
    @camera = new Camera(width, height)
    @scene = new THREE.Scene()
    @renderer = new THREE.WebGLRenderer()
    @container = document.getElementById 'container'
    @container.appendChild(@renderer.domElement)
    
document.addEventListener 'DOMContentLoaded', ->
  window.world = new World '100%', '100%'

