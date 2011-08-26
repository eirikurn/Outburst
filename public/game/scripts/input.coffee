class Input
  constructor: (@camera, @worldMap) ->
    document.addEventListener 'keyup', (ev) => @keyup(ev)
    document.addEventListener 'keydown', (ev) => @keydown(ev)
    document.addEventListener 'mousemove', (ev) => @mousemove(ev)
    document.addEventListener 'mousedown', (ev) => @mousedown(ev)
    document.addEventListener 'mouseup', (ev) => @mouseup(ev)
    document.addEventListener 'mousewheel', (ev) => @mousescroll(ev)
    document.addEventListener 'DOMMouseScroll', (ev) => @mousescroll(ev)
    
    @projector = new THREE.Projector()
    @mouse2D = new THREE.Vector3( 0, 10000, 0.5 );
    @ray = new THREE.Ray( @camera.position, null );
  
  keys:
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    65: 'left' # A
    87: 'up' # W
    68: 'right' # D
    83: 'down' # S
    
  mouse:
    x: 0
    y: 0
    down: false
    scroll: 1000
    
  keydown: (event) ->
    @[@keys[event.keyCode]] = true
  
  keyup: (event) ->
    @[@keys[event.keyCode]] = false
    
  mousemove: (event) ->
    container = document.getElementById "container"
    
    @mouse2D.x = ( event.clientX / window.innerWidth ) * 2 - 1
    @mouse2D.y = - ( event.clientY / window.innerHeight ) * 2 + 1
    
    @mouse2D.x = (event.clientX - container.offsetLeft) / container.clientWidth * 2 - 1
    @mouse2D.y = - (event.clientY - container.offsetTop) / container.clientHeight * 2 + 1
    
    mouse3D = @projector.unprojectVector( @mouse2D.clone(), @camera );
    @ray.direction = mouse3D.subSelf( @camera.position ).normalize();
    intersects = @ray.intersectObject ( @worldMap );
    if intersects.length > 0
      @mouse.x = intersects[0].point.x
      @mouse.y = intersects[0].point.y
    
  mousedown: (event) ->
    event.preventDefault()
    @mouse.down = true
    
  mouseup: (event) ->
    event.preventDefault()
    @mouse.down = false
  
  mousescroll: (event) ->
    event.preventDefault()
    val = @mouse.scroll + (event.wheelDeltaY / 10)
    @mouse.scroll = val if val > 300 and val <= 1000 


# export
@Input = Input