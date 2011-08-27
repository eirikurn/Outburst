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

# export
@World = World