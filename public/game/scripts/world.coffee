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
    
    @testPlayer = new Player(@scene)
    @cursor = new Cursor(@scene)
  
  render: ->
    @renderer.render(@scene, @camera)
  
  update: (delta) ->
    @testPlayer.update delta
    @cursor.update delta

# export
@World = World