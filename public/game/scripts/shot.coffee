class Shot extends THREE.Object3D
  constructor: (@fromX, @fromY, @direction) ->
    super()
    @position.x = @fromX
    @position.y = @fromY
    @time = 0.5
    @timeLeft = @time
    @isAlive = yes
    @createGraphic()
   
    
  createGraphic: ->
    @line = new THREE.Mesh(new THREE.CubeGeometry(1000, 2, 2, 1, 1, 1), new THREE.MeshLambertMaterial(color: 0xFFFFFF, opacity: 0.5, transparent: true))
    lineContainer = new THREE.Object3D()
    
    @line.rotation.x = Math.PI / 2
    @line.rotation.y = Math.PI / 2
    @line.position.y = 550
    @line.position.z = 120
    
    lineContainer.rotation.z = -Math.PI / 2 + @direction
    
    lineContainer.addChild @line
    @addChild lineContainer
    
  onFrame: (delta) ->
    @timeLeft -= delta
    
    if @timeLeft <= 0
      @isAlive = no
    else
      @line.materials[0].opacity = @timeLeft / @time
    
# export
@Shot = Shot
