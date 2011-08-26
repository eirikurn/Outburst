class World
  constructor: () ->
    @targetWidth = 1024
    @targetHeight = 576
    
    @camera = new Camera(@targetWidth, @targetHeight)
    @scene = new THREE.Scene()
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize(@targetWidth, @targetHeight)
    @renderer.setClearColorHex 0xFFFFFF
    @container = document.getElementById 'container'
    @container.style.width = @targetWidth + 'px'
    @container.style.height = @targetHeight + 'px'
    @container.appendChild(@renderer.domElement)
    
    @map = new Map()
    @scene.addChild(@map)
    @testPlayer = new Player(@scene)
    
    window.onresize = =>
      @resizeToFit()
      
    @resizeToFit()
  
  render: ->
    @renderer.render(@scene, @camera)
  
  update: (delta) ->
    @testPlayer.update delta
    
  resizeToFit: ->
    setWidth = window.innerWidth
    setHeight = Math.floor setWidth * (@targetHeight / @targetWidth)
    
    if setWidth > window.innerWidth
      setWidth = window.innerWidth
      setHeight = Math.floor setWidth * (@targetHeight / @targetWidth)
    
    if setHeight > window.innerHeight - 3
      setHeight = window.innerHeight - 3
      setWidth = Math.floor setHeight * (@targetWidth / @targetHeight)
    
    @renderer.setSize setWidth, setHeight
    container = document.getElementById('container')
    container.style.width = setWidth + "px"
    container.style.height = setHeight + "px"
    

# export
@World = World