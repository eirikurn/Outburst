class Input
  constructor: ->
    @targetWidth = 1024
    @targetHeight = 576
    document.addEventListener 'keyup', (ev) => @keyup(ev)
    document.addEventListener 'keydown', (ev) => @keydown(ev)
    document.addEventListener 'mousemove', (ev) => @mousemove(ev)
    document.addEventListener 'mousedown', (ev) => @mousedown(ev)
    document.addEventListener 'mouseup', (ev) => @mouseup(ev)
    document.addEventListener 'DOMMouseScroll', (ev) => @mousescroll(ev)
    
    @windowHalfX = window.innerWidth / 2
    @windowHalfY = window.innerHeight / 2
  
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
    scroll: 0
    
  keydown: (event) ->
    @[@keys[event.keyCode]] = true
  
  keyup: (event) ->
    @[@keys[event.keyCode]] = false

  getState: (s = {}) ->
    s.left = @left
    s.up = @up
    s.down = @down
    s.right = @right
    s.mouseX = @mouse.x
    s.mouseX = @mouse.y
    s.mouseDown = @mouse.down
    s
    
  mousemove: (event) ->
    container = document.getElementById "container"
    
    # Imaginary pixels
    @mouse.x = Math.round (event.clientX - container.offsetLeft) / container.clientWidth * @targetWidth - @targetWidth / 2
    @mouse.y = -Math.round (event.clientY - container.offsetTop) / container.clientHeight * @targetHeight - @targetHeight / 2
    
    # Scales
    #@mouse.x = (event.clientX - container.offsetLeft) / container.clientWidth - .5
    #@mouse.y = - (event.clientY - container.offsetTop) / container.clientHeight + .5
    
    document.getElementById('mouse').innerHTML = 'X: ' + @mouse.x + ', Y: ' + @mouse.y
    
  mousedown: (event) ->
    @mouse.down = true
    
  mouseup: (event) ->
    @mouse.down = false
  
  mousescroll: (event) ->
    @mouse.scroll += event.wheelDeltaY


# export
@Input = Input
