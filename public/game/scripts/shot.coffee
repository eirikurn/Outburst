class Shot extends THREE.Object3D
  constructor: (@state) ->
    super()
    @position.x = @state.x
    @position.y = @state.y
    @time = 0.5
    @timeLeft = @time
    @isAlive = yes
    @createGraphic()
   
    
  createGraphic: ->
    @line = new THREE.Mesh(new THREE.CubeGeometry(@state.length, 2, 2, 1, 1, 1), new THREE.MeshLambertMaterial(color: 0xFFFFFF, opacity: 0.5, transparent: true))
    lineContainer = new THREE.Object3D()
    
    @line.rotation.x = Math.PI / 2
    @line.rotation.y = Math.PI / 2
    @line.position.y = @state.length / 2
    @line.position.z = 195
    
    lineContainer.rotation.z = -Math.PI / 2 + @state.direction
    
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
